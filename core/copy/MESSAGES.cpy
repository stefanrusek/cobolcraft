*> Messages the core composes (standin-content §10.7), transcribed. Server-sent messages are
*> `translate` text components whose arguments are plain literal text components
*> (docs/protocol/09-cobolcraft-profile.md §1; contracts/wire-profile.md §1 message rule).
*> Tested by core/tests/test_content_tables.cob.
*> Argument kinds: the victim's name, the attacker's name.
 78 MSG-ARG-VICTIM            VALUE 1.
 78 MSG-ARG-ATTACKER          VALUE 2.
*> Death messages (§10.7), indexed by the cause of RULES.cpy (CAUSE-FALL 1 to CAUSE-COMMAND 6):
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
 01 DEATH-MESSAGE-TABLE REDEFINES DEATH-MESSAGE-DATA.
    05 DTH-ENTRY OCCURS 6 TIMES.
       10 DTH-KEY               PIC X(40).
       10 DTH-KEY-LENGTH        BINARY-LONG.
       10 DTH-ARG-COUNT         BINARY-LONG.
       10 DTH-ARG-KIND          BINARY-LONG OCCURS 2 TIMES.
