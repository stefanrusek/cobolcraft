*> Implementation test of the US2 content copybooks (core/copy/BLOCKS.cpy, ITEMS.cpy, ENTITYTYPES.cpy,
*> RULES.cpy, DIMENSIONS.cpy) against docs/design/standin-content.md: blocks §1.1, block
*> states §1.2, items §2 with food values §11.5 and attack damage §10.4, entity types §3 and §12.1, the
*> dimensions and spawn point §5.1, §5.2, §15, maximum health §10.1 and maximum food §11.1,
*> the health and death rules of §10.2 to §10.6 and the hunger rules of §11.2, §11.3 and §11.6
*> (RULES.cpy), the death messages of §10.7 (MESSAGES.cpy), the mob rules of §12 (MOBS.cpy), the
*> recipes of §13 (RECIPES.cpy), the weather of §14 (WEATHER.cpy), the console's en_us texts of
*> docs/protocol/08-resource-packs.md §10.8.2 to §10.8.4 (CONSOLELANG.cpy), the command set, tree and
*> usage strings of §16 (COMMANDS.cpy) and the §16 and §17 message keys (MESSAGES.cpy),
*> every synchronized registry entry of §4 (§4.2 to §4.8) and the starting inventory of §2 (US4-8).
*> Each table row is rendered as one line of text, fields separated by single spaces, and compared
*> with the row transcribed from the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-TABLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY ITEMS.
 COPY ENTITYTYPES.
 COPY RULES.
 COPY MESSAGES.
 COPY DIMENSIONS.
 COPY MOBS.
 COPY RECIPES.
 COPY WEATHER.
 COPY CONSOLELANG.
 COPY COMMANDS.
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
 01 WS-TREE-ROWS.
    05 FILLER PIC X(64) VALUE
        "  howto *exec*".
    05 FILLER PIC X(64) VALUE
        "  roster *exec*".
    05 FILLER PIC X(64) VALUE
        "  murmur".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <message> *exec* | 5 2 0 0 0".
    05 FILLER PIC X(64) VALUE
        "  promote".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  demote".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  eject".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <reason> *exec* | 5 2 0 0 0".
    05 FILLER PIC X(64) VALUE
        "  bar".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  unbar".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  barlist *exec*".
    05 FILLER PIC X(64) VALUE
        "  guestlist".
    05 FILLER PIC X(64) VALUE
        "    on *exec*".
    05 FILLER PIC X(64) VALUE
        "    off *exec*".
    05 FILLER PIC X(64) VALUE
        "    add".
    05 FILLER PIC X(64) VALUE
        "      <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "    remove".
    05 FILLER PIC X(64) VALUE
        "      <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "    show *exec*".
    05 FILLER PIC X(64) VALUE
        "  mode".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      survival *exec*".
    05 FILLER PIC X(64) VALUE
        "      creative *exec*".
    05 FILLER PIC X(64) VALUE
        "  relocate".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      at".
    05 FILLER PIC X(64) VALUE
        "        <x> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "          <y> | 2 0 0 256 0".
    05 FILLER PIC X(64) VALUE
        "            <z> *exec* | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "              <dimension> *exec* | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      to".
    05 FILLER PIC X(64) VALUE
        "        <target> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  supply".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <item> *exec* | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "        <count> *exec* | 3 0 1 2304 0".
    05 FILLER PIC X(64) VALUE
        "  empty".
    05 FILLER PIC X(64) VALUE
        "    <player> *exec* | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  vitality".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <amount> *exec* | 3 0 0 30 0".
    05 FILLER PIC X(64) VALUE
        "      full *exec*".
    05 FILLER PIC X(64) VALUE
        "      zero *exec*".
    05 FILLER PIC X(64) VALUE
        "  ration".
    05 FILLER PIC X(64) VALUE
        "    <player> | 7 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <amount> *exec* | 3 0 0 24 0".
    05 FILLER PIC X(64) VALUE
        "      full *exec*".
    05 FILLER PIC X(64) VALUE
        "      zero *exec*".
    05 FILLER PIC X(64) VALUE
        "  conjure".
    05 FILLER PIC X(64) VALUE
        "    <mob> | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      <x> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "        <y> | 2 0 0 256 0".
    05 FILLER PIC X(64) VALUE
        "          <z> *exec* | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "            <dimension> *exec* | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "  sweep".
    05 FILLER PIC X(64) VALUE
        "    <what> | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      everywhere *exec*".
    05 FILLER PIC X(64) VALUE
        "      area".
    05 FILLER PIC X(64) VALUE
        "        <dimension> | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "          <x1> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "            <y1> | 2 0 0 256 0".
    05 FILLER PIC X(64) VALUE
        "              <z1> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "                <x2> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "                  <y2> | 2 0 0 256 0".
    05 FILLER PIC X(64) VALUE
        "                    <z2> *exec* | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "  clock".
    05 FILLER PIC X(64) VALUE
        "    <ticks> *exec* | 3 0 0 29999 0".
    05 FILLER PIC X(64) VALUE
        "  skies".
    05 FILLER PIC X(64) VALUE
        "    <dimension> | 5 0 0 0 1".
    05 FILLER PIC X(64) VALUE
        "      clear *exec*".
    05 FILLER PIC X(64) VALUE
        "        <seconds> *exec* | 3 0 1 86400 0".
    05 FILLER PIC X(64) VALUE
        "      drizzle *exec*".
    05 FILLER PIC X(64) VALUE
        "        <seconds> *exec* | 3 0 1 86400 0".
    05 FILLER PIC X(64) VALUE
        "      hailstorm *exec*".
    05 FILLER PIC X(64) VALUE
        "        <seconds> *exec* | 3 0 1 86400 0".
    05 FILLER PIC X(64) VALUE
        "  homestead".
    05 FILLER PIC X(64) VALUE
        "    <x> | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "      <y> | 2 0 0 256 0".
    05 FILLER PIC X(64) VALUE
        "        <z> *exec* | 2 0 -30000000 30000000 0".
    05 FILLER PIC X(64) VALUE
        "  announce".
    05 FILLER PIC X(64) VALUE
        "    <message> *exec* | 5 2 0 0 0".
    05 FILLER PIC X(64) VALUE
        "  persist *exec*".
    05 FILLER PIC X(64) VALUE
        "  shutdown *exec*".
 01 WS-TREE-TABLE REDEFINES WS-TREE-ROWS.
    05 WS-TREE-ROW         PIC X(64) OCCURS 89 TIMES.
 01 WS-USAGE-ROWS.
    05 FILLER PIC X(64) VALUE "howto".
    05 FILLER PIC X(64) VALUE "roster".
    05 FILLER PIC X(64) VALUE "murmur <player> <message...>".
    05 FILLER PIC X(64) VALUE "promote <player>".
    05 FILLER PIC X(64) VALUE "demote <player>".
    05 FILLER PIC X(64) VALUE "eject <player> [<reason...>]".
    05 FILLER PIC X(64) VALUE "bar <player>".
    05 FILLER PIC X(64) VALUE "unbar <player>".
    05 FILLER PIC X(64) VALUE "barlist".
    05 FILLER PIC X(64) VALUE "guestlist on".
    05 FILLER PIC X(64) VALUE "guestlist off".
    05 FILLER PIC X(64) VALUE "guestlist add <player>".
    05 FILLER PIC X(64) VALUE "guestlist remove <player>".
    05 FILLER PIC X(64) VALUE "guestlist show".
    05 FILLER PIC X(64) VALUE "mode <player> survival".
    05 FILLER PIC X(64) VALUE "mode <player> creative".
    05 FILLER PIC X(64) VALUE "relocate <player> at <x> <y> <z> [<dimension>]".
    05 FILLER PIC X(64) VALUE "relocate <player> to <target>".
    05 FILLER PIC X(64) VALUE "supply <player> <item> [<count>]".
    05 FILLER PIC X(64) VALUE "empty <player>".
    05 FILLER PIC X(64) VALUE "vitality <player> <amount>".
    05 FILLER PIC X(64) VALUE "vitality <player> full".
    05 FILLER PIC X(64) VALUE "vitality <player> zero".
    05 FILLER PIC X(64) VALUE "ration <player> <amount>".
    05 FILLER PIC X(64) VALUE "ration <player> full".
    05 FILLER PIC X(64) VALUE "ration <player> zero".
    05 FILLER PIC X(64) VALUE "conjure <mob> <x> <y> <z> [<dimension>]".
    05 FILLER PIC X(64) VALUE "sweep <what> everywhere".
    05 FILLER PIC X(64) VALUE "sweep <what> area <dimension> <x1> <y1> <z1> <x2> <y2> <z2>".
    05 FILLER PIC X(64) VALUE "clock <ticks>".
    05 FILLER PIC X(64) VALUE "skies <dimension> <kind> [<seconds>]".
    05 FILLER PIC X(64) VALUE "homestead <x> <y> <z>".
    05 FILLER PIC X(64) VALUE "announce <message...>".
    05 FILLER PIC X(64) VALUE "persist".
    05 FILLER PIC X(64) VALUE "shutdown".
 01 WS-USAGE-TABLE REDEFINES WS-USAGE-ROWS.
    05 WS-USAGE-ROW        PIC X(64) OCCURS 35 TIMES.
 01 WS-MESSAGE-ROWS.
    05 FILLER PIC X(64) VALUE "cobolcraft.command.unknown W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.not_permitted W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.missing_argument U".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.invalid_argument WU".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.invalid_name W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.player_not_found W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.dimension_not_found W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.item_not_found W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.mob_not_found W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.not_survival W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.promote.notice".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.demote.notice".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.not_alive W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.is_host W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.howto.header I".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.howto.entry U".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.roster IL".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.murmur.incoming WT".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.murmur.incoming_console T".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.murmur.sent WT".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.promote.done W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.promote.already W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.demote.done W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.demote.not_operator W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.eject.done W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.bar.done W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.bar.already W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.unbar.done W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.unbar.not_barred W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.barlist IL".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.on".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.off".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.added W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.already W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.removed W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.not_listed W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.guestlist.show WIL".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.mode.done WW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.relocate.position WDDDW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.relocate.player WW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.supply.done IWW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.supply.no_room W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.empty.done WI".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.vitality.done WI".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.ration.done WI".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.conjure.done WDDDW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.conjure.hostile_disabled W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.sweep.done I".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.sweep.unknown_target W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.clock.done I".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.skies.timed WWI".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.skies.held WW".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.skies.no_weather W".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.homestead.done DDD".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.announce.message T".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.announce.done".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.persist.done".
    05 FILLER PIC X(64) VALUE "cobolcraft.command.shutdown.done".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.barred".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.not_on_guestlist".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.name_is_host W".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.replaced".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.shutdown".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.host_closed".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.pack_required".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.ejected T".
    05 FILLER PIC X(64) VALUE "cobolcraft.disconnect.ejected_plain".
 01 WS-MESSAGE-TABLE REDEFINES WS-MESSAGE-ROWS.
    05 WS-MESSAGE-ROW      PIC X(64) OCCURS 67 TIMES.
 01 WS-ROW                 PIC X(400).
 01 WS-J                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
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
       "cobolcraft:main 0 cobolcraft:surface 0 256 48 1 1 1 1 -1 0 2 5 2".
    05 FILLER PIC X(100) VALUE
       "cobolcraft:subroutine 1 cobolcraft:sunless 0 128 32 2 2 0 0 2 1 1 5 2".
    05 FILLER PIC X(100) VALUE
       "minecraft:overworld 0 minecraft:overworld -64 384 63 3 1 1 1 -1 2 0 16 7".
 01 WS-DIMENSION-TABLE REDEFINES WS-DIMENSION-ROWS.
    05 WS-DIMENSION-ROW    PIC X(100) OCCURS 3 TIMES.
 PROCEDURE DIVISION.
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
         MOVE DM-BLOCK-BITS(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-BIOME-BITS(WS-I) TO WS-NUM PERFORM ADD-NUM
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
     MOVE "1 2 3 1 2 1 2" TO TL-EXPECTED
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

     MOVE "test content tables day length (shared rule 33 §3: Time 0 to 23999)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24000 TO TL-EXPECTED-N
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

*>   The command set of standin §16 (COMMANDS.cpy; FR-016): each command with its permission (§16.2
*>   "Who": 0 everyone, 1 operator) and its node in the tree; the tree of 09 §3.3 / standin §16.3
*>   (depth-first pre-order, indented two spaces per level, *exec* where a usage string may end,
*>   argument nodes with parser id, string kind, minimum, maximum and the ask_server flag); the
*>   usage strings of §16.2 in table order; the §16 and §17 translation keys with the kinds of their
*>   arguments (W a word or name, I an integer, D a double, L a name list, U a usage string, T text).
     MOVE "test content tables commands (§16.2: name, permission, tree node)" TO TL-CASE
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CMD-COUNT
         PERFORM ADD-SPACE
         STRING CD-NAME(WS-I)(1:CD-NAME-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE CD-PERMISSION(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE CD-NODE(WS-I) TO WS-NUM PERFORM ADD-NUM
     END-PERFORM
     MOVE "howto 0 1 roster 0 2 murmur 0 3 promote 1 6 demote 1 8 eject 1 10 bar 1 13 unbar 1 15 "
         & "barlist 1 17 guestlist 1 18 mode 1 26 relocate 1 30 supply 1 39 empty 1 43 vitality 1 "
         & "45 ration 1 50 conjure 1 55 sweep 1 61 clock 1 72 skies 1 74 homestead 1 82 announce 1 "
         & "86 persist 1 88 shutdown 1 89" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE "test content tables command tree: 89 nodes under the root" TO TL-CASE
     PERFORM START-ROW
     MOVE CMD-NODE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "89" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CMD-NODE-COUNT
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-EDIT
         STRING "test content tables command tree node " FUNCTION TRIM(WS-EDIT)
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         MOVE 0 TO WS-DEPTH
         MOVE WS-I TO WS-K
         PERFORM UNTIL WS-K = 0
             ADD 1 TO WS-DEPTH
             MOVE CT-PARENT(WS-K) TO WS-K
         END-PERFORM
         COMPUTE WS-PTR = WS-DEPTH * 2 + 1
         IF CT-TYPE(WS-I) = 2
             STRING "<" CT-NAME(WS-I)(1:CT-NAME-LENGTH(WS-I)) ">" DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         ELSE
             STRING CT-NAME(WS-I)(1:CT-NAME-LENGTH(WS-I)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         IF CT-EXEC(WS-I) = 1
             STRING " *exec*" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         IF CT-TYPE(WS-I) = 2
             STRING " |" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
             MOVE CT-PARSER(WS-I) TO WS-NUM PERFORM ADD-NUM
             MOVE CT-STRING-KIND(WS-I) TO WS-NUM PERFORM ADD-NUM
             MOVE CT-MIN(WS-I) TO WS-NUM PERFORM ADD-NUM
             MOVE CT-MAX(WS-I) TO WS-NUM PERFORM ADD-NUM
             MOVE CT-SUGGEST(WS-I) TO WS-NUM PERFORM ADD-NUM
         END-IF
         MOVE WS-TREE-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM
     MOVE "test content tables command usage strings: 35" TO TL-CASE
     PERFORM START-ROW
     MOVE CMD-USAGE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "35" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CMD-USAGE-COUNT
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-EDIT
         STRING "test content tables command usage " FUNCTION TRIM(WS-EDIT)
             " (of its command)" DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         STRING CU-TEXT(WS-I)(1:CU-LENGTH(WS-I)) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE WS-USAGE-ROW(WS-I) TO TL-EXPECTED
         MOVE CU-COMMAND(WS-I) TO WS-K
         MOVE CD-NAME-LENGTH(WS-K) TO WS-J
         IF CD-NAME(WS-K)(1:WS-J) NOT = CU-TEXT(WS-I)(1:WS-J)
             MOVE "wrong command" TO WS-ROW
         END-IF
         PERFORM ASSERT-ROW
     END-PERFORM
     MOVE "test content tables command and system messages: 67 keys" TO TL-CASE
     PERFORM START-ROW
     MOVE MK-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "67" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MK-COUNT
         MOVE SPACES TO TL-CASE
         STRING "test content tables message " MKEY-KEY(WS-I)(1:MKEY-KEY-LENGTH(WS-I))
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         STRING MKEY-KEY(WS-I)(1:MKEY-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         IF MKEY-ARGS-COUNT(WS-I) > 0
             STRING " " MKEY-ARGS(WS-I)(1:MKEY-ARGS-COUNT(WS-I)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         MOVE WS-MESSAGE-ROW(WS-I) TO TL-EXPECTED
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
