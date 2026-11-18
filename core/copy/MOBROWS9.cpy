*> Rows added by lane p49d (T18000 ff.), included by STDMOBS.cpy after MOBROWS8.cpy (the villager rows and the strider stay the last four). Columns as the rows there.
*> SM-KIND 5 is the axolotl (spawn category 4, axolotls) and 6 the aquatic monsters (guardian, elder guardian: category 1, removed on Peaceful like kind 1); both are water mobs that
*> STDMOB-AQUATIC-STEP hands to AXOLOTL-TICK / GUARDIAN-TICK. SM-SPAWN 12 axolotl (clay below), 13 guardian, 14 drowned: AQUA-SPAWN-RULE (21 section 3.2).
*> Animal base + MAX_HEALTH 14, MOVEMENT_SPEED 1.0, ATTACK_DAMAGE 2.0 (21 section 4.7); the walk is the idle swim modifier 0.5 (x 1000: AQUA-SWIM's units); kind 5 = axolotl (category 4, AXOLOTL-TICK)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "axolotl".
       10 FILLER BINARY-LONG VALUE 14.  *> max health
       10 FILLER BINARY-LONG VALUE 500.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 0.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 5.  *> kind
       10 FILLER BINARY-LONG VALUE 2.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 12.  *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
*> Monster base + ATTACK_DAMAGE 6, MOVEMENT_SPEED 0.5, MAX_HEALTH 30 (21 section 4.8): the stroll modifier 1.0 x 0.5; kind 6 = aquatic monster (category 1, GUARDIAN-TICK); experience 10
    05 FILLER.
       10 FILLER PIC X(24) VALUE "guardian".
       10 FILLER BINARY-LONG VALUE 30.  *> max health
       10 FILLER BINARY-LONG VALUE 500.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 0.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 6.  *> kind
       10 FILLER BINARY-LONG VALUE 6.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral
       10 FILLER BINARY-LONG VALUE 10.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 13.  *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
*> Guardian attributes + MOVEMENT_SPEED 0.3, ATTACK_DAMAGE 8, MAX_HEALTH 80; experience 10
    05 FILLER.
       10 FILLER PIC X(24) VALUE "elder_guardian".
       10 FILLER BINARY-LONG VALUE 80.  *> max health
       10 FILLER BINARY-LONG VALUE 300.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 0.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 6.  *> kind
       10 FILLER BINARY-LONG VALUE 8.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral
       10 FILLER BINARY-LONG VALUE 10.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 13.  *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
*> The zombie's row (20 section 4.5: attributes as Zombie), spawn rule 14: the Drowned predicate of 21 section 3.2 (placement IN_WATER); its water goals and trident are 20 section 4.5
    05 FILLER.
       10 FILLER PIC X(24) VALUE "drowned".
       10 FILLER BINARY-LONG VALUE 20.  *> max health
       10 FILLER BINARY-LONG VALUE 117.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 0.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 1.  *> kind
       10 FILLER BINARY-LONG VALUE 3.  *> attack damage
       10 FILLER BINARY-LONG VALUE 35.  *> follow range
       10 FILLER BINARY-LONG VALUE 1.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 14.  *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
