*> The en_us text of the vanilla death messages a standard world's core sends (docs/protocol/17-tools-weapons-and-combat.md
*> 4.13.2 and 4.13.3: the key, its arguments in the order victim, attacker, item, and the English sentence), used to show
*> the console line of a death (core/src/console.cob). A text has %1$s, %2$s and %3$s positional arguments. Tested by
*> core/tests/test_console_death.cob.
 78 DT-COUNT                  VALUE 19.
 01 DEATH-TEXT-DATA.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.arrow".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER PIC X(80) VALUE "%1$s was shot by %2$s".
       10 FILLER BINARY-LONG VALUE 21.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.arrow.item".
       10 FILLER BINARY-LONG VALUE 23.
       10 FILLER PIC X(80) VALUE "%1$s was shot by %2$s using %3$s".
       10 FILLER BINARY-LONG VALUE 32.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.drown".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER PIC X(80) VALUE "%1$s drowned".
       10 FILLER BINARY-LONG VALUE 12.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.drown.player".
       10 FILLER BINARY-LONG VALUE 25.
       10 FILLER PIC X(80) VALUE "%1$s drowned while trying to escape %2$s".
       10 FILLER BINARY-LONG VALUE 40.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.explosion".
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER PIC X(80) VALUE "%1$s blew up".
       10 FILLER BINARY-LONG VALUE 12.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.explosion.player".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(80) VALUE "%1$s was blown up by %2$s".
       10 FILLER BINARY-LONG VALUE 25.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.fall".
       10 FILLER BINARY-LONG VALUE 17.
       10 FILLER PIC X(80) VALUE "%1$s hit the ground too hard".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.fall.player".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER PIC X(80) VALUE "%1$s hit the ground too hard while trying to escape %2$s".
       10 FILLER BINARY-LONG VALUE 56.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.generic".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER PIC X(80) VALUE "%1$s died".
       10 FILLER BINARY-LONG VALUE 9.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.genericKill".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER PIC X(80) VALUE "%1$s was killed".
       10 FILLER BINARY-LONG VALUE 15.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.genericKill.player".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(80) VALUE "%1$s was killed while fighting %2$s".
       10 FILLER BINARY-LONG VALUE 35.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.mob".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER PIC X(80) VALUE "%1$s was slain by %2$s".
       10 FILLER BINARY-LONG VALUE 22.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.mob.item".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER PIC X(80) VALUE "%1$s was slain by %2$s using %3$s".
       10 FILLER BINARY-LONG VALUE 33.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.player".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER PIC X(80) VALUE "%1$s was slain by %2$s".
       10 FILLER BINARY-LONG VALUE 22.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.player.item".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER PIC X(80) VALUE "%1$s was slain by %2$s using %3$s".
       10 FILLER BINARY-LONG VALUE 33.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.starve".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER PIC X(80) VALUE "%1$s starved to death".
       10 FILLER BINARY-LONG VALUE 21.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.attack.starve.player".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(80) VALUE "%1$s starved to death while fighting %2$s".
       10 FILLER BINARY-LONG VALUE 41.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.fell.accident.generic".
       10 FILLER BINARY-LONG VALUE 27.
       10 FILLER PIC X(80) VALUE "%1$s fell from a high place".
       10 FILLER BINARY-LONG VALUE 27.
    05 FILLER.
       10 FILLER PIC X(40) VALUE "death.fell.assist".
       10 FILLER BINARY-LONG VALUE 17.
       10 FILLER PIC X(80) VALUE "%1$s was doomed to fall by %2$s".
       10 FILLER BINARY-LONG VALUE 31.
 01 DEATH-TEXT-TABLE REDEFINES DEATH-TEXT-DATA.
    05 DT-ENTRY OCCURS 19 TIMES.
       10 DT-KEY                PIC X(40).
       10 DT-KEY-LENGTH         BINARY-LONG.
       10 DT-TEXT               PIC X(80).
       10 DT-TEXT-LENGTH        BINARY-LONG.
