*> Messages the core composes (standin-content §10.7, §16, §17), transcribed. Server-sent messages are
*> `translate` text components whose arguments are plain literal text components
*> (docs/protocol/09-cobolcraft-profile.md §1; contracts/wire-profile.md §1 message rule).
*> Tested by core/tests/test_content_tables.cob.
*> Argument kinds: the victim's name, the attacker's name.
 78 MSG-ARG-VICTIM            VALUE 1.
 78 MSG-ARG-ATTACKER          VALUE 2.
*> Death messages (§10.7), indexed by the cause of RULES.cpy (CAUSE-FALL 1 to CAUSE-DROWN 7):
*> key, key length, argument count, kinds of arguments 1 and 2 (0 = none).
 01 DEATH-MESSAGE-DATA.
    05 FILLER.                                  *> CAUSE-FALL
       10 FILLER PIC X(40) VALUE "cobolcraft.death.fall".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-ABEND
       10 FILLER PIC X(40) VALUE "cobolcraft.death.mob.abend".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-PLAYER
       10 FILLER PIC X(40) VALUE "cobolcraft.death.player".
       10 FILLER BINARY-LONG VALUE 23.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> CAUSE-STARVATION
       10 FILLER PIC X(40) VALUE "cobolcraft.death.starvation".
       10 FILLER BINARY-LONG VALUE 27.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-HAIL
       10 FILLER PIC X(40) VALUE "cobolcraft.death.hail".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-COMMAND
       10 FILLER PIC X(40) VALUE "cobolcraft.death.command".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-MOB: the vanilla message of the mob_attack damage type (standard worlds)
       10 FILLER PIC X(40) VALUE "death.attack.mob".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> CAUSE-DROWN (the vanilla translate key, 17 4.12: death.attack.drown has the victim)
       10 FILLER PIC X(40) VALUE "death.attack.drown".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-EXPLOSION (002-lane-mobs2)
       10 FILLER PIC X(40) VALUE "death.attack.explosion".
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-ARROW (002-lane-mobs2)
       10 FILLER PIC X(40) VALUE "death.attack.arrow".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
 01 DEATH-MESSAGE-TABLE REDEFINES DEATH-MESSAGE-DATA.
    05 DTH-ENTRY OCCURS 10 TIMES.
       10 DTH-KEY               PIC X(40).
       10 DTH-KEY-LENGTH        BINARY-LONG.
       10 DTH-ARG-COUNT         BINARY-LONG.
       10 DTH-ARG-KIND          BINARY-LONG OCCURS 2 TIMES.
*> The death messages of a standard set (17 section 4.13.2: death.attack.<message_id> of the cause's damage type; victim, then attacker), indexed like
*> DEATH-MESSAGE-TABLE: key, key length, argument count, kinds of arguments 1 and 2.
 01 DEATH-STD-DATA.
    05 FILLER.                                  *> CAUSE-FALL
       10 FILLER PIC X(40) VALUE "death.attack.fall".
       10 FILLER BINARY-LONG VALUE 17.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-ABEND
       10 FILLER PIC X(40) VALUE "death.attack.mob".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> CAUSE-PLAYER
       10 FILLER PIC X(40) VALUE "death.attack.player".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> CAUSE-STARVATION
       10 FILLER PIC X(40) VALUE "death.attack.starve".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-HAIL
       10 FILLER PIC X(40) VALUE "death.attack.generic".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-COMMAND
       10 FILLER PIC X(40) VALUE "death.attack.genericKill".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-MOB
       10 FILLER PIC X(40) VALUE "death.attack.mob".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> CAUSE-DROWN
       10 FILLER PIC X(40) VALUE "death.attack.drown".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-EXPLOSION (002-lane-mobs2)
       10 FILLER PIC X(40) VALUE "death.attack.explosion".
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> CAUSE-ARROW (002-lane-mobs2)
       10 FILLER PIC X(40) VALUE "death.attack.arrow".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
 01 DEATH-STD-TABLE REDEFINES DEATH-STD-DATA.
    05 DTS-ENTRY OCCURS 10 TIMES.
       10 DTS-KEY               PIC X(40).
       10 DTS-KEY-LENGTH        BINARY-LONG.
       10 DTS-ARG-COUNT         BINARY-LONG.
       10 DTS-ARG-KIND          BINARY-LONG OCCURS 2 TIMES.
*> Command and system messages (standin-content §16.2, §16.4, §17), transcribed: the translate key
*> and the kinds of its arguments, in order (every argument is a plain literal text component,
*> §16.1 'Arguments in messages'): W a word or name as written, I an integer in decimal, D a double
*> with two decimals, L names joined by ', ', U a usage string, T a text as written (message,
*> reason). Index the table by the MK-* constants.
*> Command messages (§16.2, §16.4), then system messages (§17, MK-DC-*).
 78 MK-UNKNOWN                      VALUE 1.
 78 MK-NOT-PERMITTED                VALUE 2.
 78 MK-MISSING-ARGUMENT             VALUE 3.
 78 MK-INVALID-ARGUMENT             VALUE 4.
 78 MK-INVALID-NAME                 VALUE 5.
 78 MK-PLAYER-NOT-FOUND             VALUE 6.
 78 MK-DIMENSION-NOT-FOUND          VALUE 7.
 78 MK-ITEM-NOT-FOUND               VALUE 8.
 78 MK-MOB-NOT-FOUND                VALUE 9.
 78 MK-NOT-SURVIVAL                 VALUE 10.
 78 MK-PROMOTE-NOTICE               VALUE 11.
 78 MK-DEMOTE-NOTICE                VALUE 12.
 78 MK-NOT-ALIVE                    VALUE 13.
 78 MK-IS-HOST                      VALUE 14.
 78 MK-HOWTO-HEADER                 VALUE 15.
 78 MK-HOWTO-ENTRY                  VALUE 16.
 78 MK-ROSTER                       VALUE 17.
 78 MK-MURMUR-INCOMING              VALUE 18.
 78 MK-MURMUR-INCOMING-CONSOLE      VALUE 19.
 78 MK-MURMUR-SENT                  VALUE 20.
 78 MK-PROMOTE-DONE                 VALUE 21.
 78 MK-PROMOTE-ALREADY              VALUE 22.
 78 MK-DEMOTE-DONE                  VALUE 23.
 78 MK-DEMOTE-NOT-OPERATOR          VALUE 24.
 78 MK-EJECT-DONE                   VALUE 25.
 78 MK-BAR-DONE                     VALUE 26.
 78 MK-BAR-ALREADY                  VALUE 27.
 78 MK-UNBAR-DONE                   VALUE 28.
 78 MK-UNBAR-NOT-BARRED             VALUE 29.
 78 MK-BARLIST                      VALUE 30.
 78 MK-GUESTLIST-ON                 VALUE 31.
 78 MK-GUESTLIST-OFF                VALUE 32.
 78 MK-GUESTLIST-ADDED              VALUE 33.
 78 MK-GUESTLIST-ALREADY            VALUE 34.
 78 MK-GUESTLIST-REMOVED            VALUE 35.
 78 MK-GUESTLIST-NOT-LISTED         VALUE 36.
 78 MK-GUESTLIST-SHOW               VALUE 37.
 78 MK-MODE-DONE                    VALUE 38.
 78 MK-RELOCATE-POSITION            VALUE 39.
 78 MK-RELOCATE-PLAYER              VALUE 40.
 78 MK-SUPPLY-DONE                  VALUE 41.
 78 MK-SUPPLY-NO-ROOM               VALUE 42.
 78 MK-EMPTY-DONE                   VALUE 43.
 78 MK-VITALITY-DONE                VALUE 44.
 78 MK-RATION-DONE                  VALUE 45.
 78 MK-CONJURE-DONE                 VALUE 46.
 78 MK-CONJURE-HOSTILE-DISABLED     VALUE 47.
 78 MK-SWEEP-DONE                   VALUE 48.
 78 MK-SWEEP-UNKNOWN-TARGET         VALUE 49.
 78 MK-CLOCK-DONE                   VALUE 50.
 78 MK-SKIES-TIMED                  VALUE 51.
 78 MK-SKIES-HELD                   VALUE 52.
 78 MK-SKIES-NO-WEATHER             VALUE 53.
 78 MK-HOMESTEAD-DONE               VALUE 54.
 78 MK-ANNOUNCE-MESSAGE             VALUE 55.
 78 MK-ANNOUNCE-DONE                VALUE 56.
 78 MK-PERSIST-DONE                 VALUE 57.
 78 MK-SHUTDOWN-DONE                VALUE 58.
 78 MK-DC-BARRED                    VALUE 59.
 78 MK-DC-NOT-ON-GUESTLIST          VALUE 60.
 78 MK-DC-NAME-IS-HOST              VALUE 61.
 78 MK-DC-REPLACED                  VALUE 62.
 78 MK-DC-SHUTDOWN                  VALUE 63.
 78 MK-DC-HOST-CLOSED               VALUE 64.
 78 MK-DC-PACK-REQUIRED             VALUE 65.
 78 MK-DC-EJECTED                   VALUE 66.
 78 MK-DC-EJECTED-PLAIN             VALUE 67.
 78 MK-COUNT                     VALUE 67.
 01 MESSAGE-KEY-DATA.
    05 FILLER.                                  *> MK-UNKNOWN
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unknown".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-NOT-PERMITTED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_permitted".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-MISSING-ARGUMENT
       10 FILLER PIC X(48) VALUE "cobolcraft.command.missing_argument".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "U".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-INVALID-ARGUMENT
       10 FILLER PIC X(48) VALUE "cobolcraft.command.invalid_argument".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "WU".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-INVALID-NAME
       10 FILLER PIC X(48) VALUE "cobolcraft.command.invalid_name".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-PLAYER-NOT-FOUND
       10 FILLER PIC X(48) VALUE "cobolcraft.command.player_not_found".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-DIMENSION-NOT-FOUND
       10 FILLER PIC X(48) VALUE "cobolcraft.command.dimension_not_found".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-ITEM-NOT-FOUND
       10 FILLER PIC X(48) VALUE "cobolcraft.command.item_not_found".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-MOB-NOT-FOUND
       10 FILLER PIC X(48) VALUE "cobolcraft.command.mob_not_found".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-NOT-SURVIVAL
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_survival".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-PROMOTE-NOTICE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.notice".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DEMOTE-NOTICE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.notice".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-NOT-ALIVE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_alive".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-IS-HOST
       10 FILLER PIC X(48) VALUE "cobolcraft.command.is_host".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-HOWTO-HEADER
       10 FILLER PIC X(48) VALUE "cobolcraft.command.howto.header".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE "I".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-HOWTO-ENTRY
       10 FILLER PIC X(48) VALUE "cobolcraft.command.howto.entry".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "U".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-ROSTER
       10 FILLER PIC X(48) VALUE "cobolcraft.command.roster".
       10 FILLER BINARY-LONG VALUE 25.
       10 FILLER PIC X(8) VALUE "IL".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-MURMUR-INCOMING
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.incoming".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(8) VALUE "WT".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-MURMUR-INCOMING-CONSOLE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.incoming_console".
       10 FILLER BINARY-LONG VALUE 42.
       10 FILLER PIC X(8) VALUE "T".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-MURMUR-SENT
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.sent".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "WT".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-PROMOTE-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-PROMOTE-ALREADY
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.already".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-DEMOTE-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-DEMOTE-NOT-OPERATOR
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.not_operator".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-EJECT-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.eject.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-BAR-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.bar.done".
       10 FILLER BINARY-LONG VALUE 27.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-BAR-ALREADY
       10 FILLER PIC X(48) VALUE "cobolcraft.command.bar.already".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-UNBAR-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unbar.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-UNBAR-NOT-BARRED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unbar.not_barred".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-BARLIST
       10 FILLER PIC X(48) VALUE "cobolcraft.command.barlist".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(8) VALUE "IL".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-GUESTLIST-ON
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.on".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-GUESTLIST-OFF
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.off".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-GUESTLIST-ADDED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.added".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-GUESTLIST-ALREADY
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.already".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-GUESTLIST-REMOVED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.removed".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-GUESTLIST-NOT-LISTED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.not_listed".
       10 FILLER BINARY-LONG VALUE 39.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-GUESTLIST-SHOW
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.show".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE "WIL".
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.                                  *> MK-MODE-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.mode.done".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(8) VALUE "WW".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-RELOCATE-POSITION
       10 FILLER PIC X(48) VALUE "cobolcraft.command.relocate.position".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(8) VALUE "WDDDW".
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.                                  *> MK-RELOCATE-PLAYER
       10 FILLER PIC X(48) VALUE "cobolcraft.command.relocate.player".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(8) VALUE "WW".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-SUPPLY-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.supply.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "IWW".
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.                                  *> MK-SUPPLY-NO-ROOM
       10 FILLER PIC X(48) VALUE "cobolcraft.command.supply.no_room".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-EMPTY-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.empty.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "WI".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-VITALITY-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.vitality.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE "WI".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-RATION-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.ration.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "WI".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-CONJURE-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.conjure.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE "WDDDW".
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.                                  *> MK-CONJURE-HOSTILE-DISABLED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.conjure.hostile_disabled".
       10 FILLER BINARY-LONG VALUE 43.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-SWEEP-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.sweep.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "I".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-SWEEP-UNKNOWN-TARGET
       10 FILLER PIC X(48) VALUE "cobolcraft.command.sweep.unknown_target".
       10 FILLER BINARY-LONG VALUE 39.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-CLOCK-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.clock.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "I".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-SKIES-TIMED
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.timed".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE "WWI".
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.                                  *> MK-SKIES-HELD
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.held".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "WW".
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> MK-SKIES-NO-WEATHER
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.no_weather".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-HOMESTEAD-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.homestead.done".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE "DDD".
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.                                  *> MK-ANNOUNCE-MESSAGE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.announce.message".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE "T".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-ANNOUNCE-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.announce.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-PERSIST-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.persist.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-SHUTDOWN-DONE
       10 FILLER PIC X(48) VALUE "cobolcraft.command.shutdown.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-BARRED
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.barred".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-NOT-ON-GUESTLIST
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.not_on_guestlist".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-NAME-IS-HOST
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.name_is_host".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(8) VALUE "W".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-DC-REPLACED
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.replaced".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-SHUTDOWN
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.shutdown".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-HOST-CLOSED
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.host_closed".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-PACK-REQUIRED
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.pack_required".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.                                  *> MK-DC-EJECTED
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.ejected".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(8) VALUE "T".
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> MK-DC-EJECTED-PLAIN
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.ejected_plain".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(8) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
 01 MESSAGE-KEY-TABLE REDEFINES MESSAGE-KEY-DATA.
    05 MKEY-ENTRY OCCURS 67 TIMES.
       10 MKEY-KEY              PIC X(48).
       10 MKEY-KEY-LENGTH       BINARY-LONG.
       10 MKEY-ARGS             PIC X(8).
       10 MKEY-ARGS-COUNT       BINARY-LONG.
