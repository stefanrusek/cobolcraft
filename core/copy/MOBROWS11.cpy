*> Rows added by lane p49f (T21100 ff.), included by STDMOBS.cpy after MOB21ROWS3.cpy (the villager rows and the strider stay the last four). Columns as the rows there.
*> The bat (21 section 8.10: max health 6; ambient category, natural spawn rule SM-SPAWN 16 = Bat.checkBatSpawnRules (12 to 14 are the aquatic rules of lane p49d); no walking: it flies, BAT-TICK; the experience is not in the
*> documents (xpReward of the bat), -1 gives none). A bat flies and never walks, so its speeds are 0.
*> The happy ghast (21 section 8.11: max health 20, movement speed 0.05 so 0.05 squared / 0.454 = 6 at the modifier 1.0, panic modifier 2.0 gives (0.05 x 2) squared / 0.454 = 22, follow
*> range 16; an animal for the experience (1 + nextInt(3)); no natural spawn: it hatches from a dried ghast, 44-9 section 9.1).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "bat".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE -1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "happy_ghast".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
