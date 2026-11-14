*> Overworld hostile rows of document 20 beyond the first slice (lane 002-lane-mobsfull-h5), included by STDMOBS.cpy after MOB19ROWS.cpy; the
*> columns are those of the rows there. SM-SPAWN 6: the slime rule (STDMOB-SLIME-RULE); 2: the monster rule in the dark.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "slime".
       10 FILLER BINARY-LONG VALUE 1.              *> max health size x size, set per slime (20 section 10); 1 at size 1
       10 FILLER BINARY-LONG VALUE 198.            *> (0.2 + 0.1 size) squared / 0.454 at size 1 (the hop cadence is not modelled, open)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.              *> attack damage size (STDMOB-ATTACK-DAMAGE)
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> experience size (STDMOB-SLIME-DIE)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "enderman".
       10 FILLER BINARY-LONG VALUE 40.
       10 FILLER BINARY-LONG VALUE 198.            *> 0.3 x 1.0 squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 7.              *> attack damage 7.0
       10 FILLER BINARY-LONG VALUE 64.             *> follow range 64
       10 FILLER BINARY-LONG VALUE 0.              *> not in burn_in_daylight
       10 FILLER BINARY-LONG VALUE 2.              *> takes a target only when stared at (20 section 8.1)
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 0.
