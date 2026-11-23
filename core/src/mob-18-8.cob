*> Love mode, feeding, ageing and breeding of the animals (docs/protocol/18-mob-framework.md section 8.1; 19 sections 2 and 3.4; lane 002-lane-mobsfull-h6),
*> and the interactions of the farm animals of document 19 section 2 (shearing, milking, bowls, eggs, grass eating) wired to the live game.
*>
*> Pure rules (species keys are PIC X(24) without "minecraft:", item keys the same):
*>   M188-FOOD USING species, item, found, seconds, love, tame        the food table: found 1 when the species accepts it; seconds the fixed age-up of a baby (0 = the 10 percent rule);
*>                                                                    love 1 when it can start love; tame 1 when love needs a tamed adult (horse family, llama, camel)
*>   M188-BREEDS USING species, ok                                    1 when the species can fall in love
*>   M188-FEED USING age, in love, found, fixed seconds, can fall in love, action out, seconds out    8.1 Animal.mobInteract: action 1 love, 2 age up, 0 nothing
*>   M188-AGE-UP USING age (changed), seconds, forced timer (changed)  8.1 ageUp: the age moves toward 0 by seconds x 20 and the forced-age effect lasts 40 ticks
*>   M188-TICK USING age, in love, locked, forced, grown out          8.1 AgeableMob.aiStep and Animal.aiStep for one tick
*>   M188-CAN-MATE USING species a, species b, love a, love b, ok     8.1 canMate
*>   M188-OFFSPRING USING species a, species b, key out               8.1 getBreedOffspring
*>   M188-COLOR-KEY USING colour (0 to 15), key out                   the wool item of a dye colour
*> Live programs:
*>   MOB-SPECIES-KEY USING row, key out                               the species key of a standard mob row (spaces for any other row)
*>   MOB-DATA-VALUES USING row, baby out, wool out, needed out        the metadata an animal sends: slot 16 the baby flag, slot 18 the sheep wool byte
*>   MOB-DATA-BUILD USING row, PB-BUFFER                              that Set Entity Data (0x65)
*>   MOB-DATA-SEND USING row                                          the same to the viewers of the row
*>   MOB-BORN USING row                                               the initial state of a new mob: a sheep's colour, a chicken's egg timer
*>   MOB-PARTNER USING row, partner out                               the nearest suitable partner of an animal in love within 8 blocks (0 none)
*>   MOB-BREED USING row a, row b                                     spawnChildFromBreeding and finalizeSpawnChildFromBreeding
*>   MOB-LIFE-TICK USING row, hx out, hz out, walk out                the age, love, egg, wool and breeding of one animal for one tick; walk 1 when it walks to its partner
*>   MOB-SHEEP-EAT-START USING row, draw (0 to the bound - 1)         the EatBlock goal starts on draw 0 when the block at the feet or the one below can be eaten
*>   MOB-SHEEP-EAT-TICK USING row                                     the eating timer: at 4 the block is eaten
*>   MOB-INTERACT USING connection id, PLAY-SERVERBOUND               Interact 0x1A on an animal

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-FOOD.
*> USING species, item, found, seconds, love, tame: 8.1 and 19 section 2 (pig_food carrot potato beetroot; cow_food, sheep_food and goat_food wheat; chicken_food the six seeds;
*> rabbit_food; fox_food; panda_food) and 3.4 (the horse family through M19-HORSE-FOOD, llama, camel cactus with its 10 s).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOODS.
    05 FILLER PIC X(48) VALUE "pig                     carrot                  ".
    05 FILLER PIC X(48) VALUE "pig                     potato                  ".
    05 FILLER PIC X(48) VALUE "pig                     beetroot                ".
    05 FILLER PIC X(48) VALUE "cow                     wheat                   ".
    05 FILLER PIC X(48) VALUE "mooshroom               wheat                   ".
    05 FILLER PIC X(48) VALUE "sheep                   wheat                   ".
    05 FILLER PIC X(48) VALUE "goat                    wheat                   ".
    05 FILLER PIC X(48) VALUE "chicken                 wheat_seeds             ".
    05 FILLER PIC X(48) VALUE "chicken                 melon_seeds             ".
    05 FILLER PIC X(48) VALUE "chicken                 pumpkin_seeds           ".
    05 FILLER PIC X(48) VALUE "chicken                 beetroot_seeds          ".
    05 FILLER PIC X(48) VALUE "chicken                 torchflower_seeds       ".
    05 FILLER PIC X(48) VALUE "chicken                 pitcher_pod             ".
    05 FILLER PIC X(48) VALUE "rabbit                  carrot                  ".
    05 FILLER PIC X(48) VALUE "rabbit                  golden_carrot           ".
    05 FILLER PIC X(48) VALUE "rabbit                  dandelion               ".
    05 FILLER PIC X(48) VALUE "fox                     sweet_berries           ".
    05 FILLER PIC X(48) VALUE "fox                     glow_berries            ".
    05 FILLER PIC X(48) VALUE "panda                   bamboo                  ".
 01 WS-FOOD-TABLE REDEFINES WS-FOODS.
    05 WS-FOOD               OCCURS 19 TIMES.
       10 WS-F-SPECIES       PIC X(24).
       10 WS-F-ITEM          PIC X(24).
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-HEAL                BINARY-LONG.
 01 WS-TEMPER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-ITEM                 PIC X(24).
 01 L-FOUND                BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-LOVE                 BINARY-LONG.
 01 L-TAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-ITEM L-FOUND L-SECONDS L-LOVE L-TAME.
     MOVE 0 TO L-FOUND L-SECONDS L-LOVE L-TAME WS-HORSE WS-KIND
     EVALUATE TRUE
         WHEN L-SPECIES = "horse" OR "donkey" OR "mule"
             MOVE 1 TO WS-HORSE
         WHEN L-SPECIES = "llama"
             MOVE 1 TO WS-HORSE
             MOVE 1 TO WS-KIND
         WHEN L-SPECIES = "camel"
             MOVE 1 TO WS-HORSE
             MOVE 2 TO WS-KIND
     END-EVALUATE
     IF WS-HORSE = 1
         CALL "M19-HORSE-FOOD" USING WS-KIND L-ITEM L-FOUND WS-HEAL L-SECONDS WS-TEMPER L-LOVE
         MOVE 1 TO L-TAME
         IF L-FOUND = 1 AND WS-KIND = 2
             MOVE 10 TO L-SECONDS
         END-IF
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
             IF WS-F-SPECIES(WS-I) = L-SPECIES AND WS-F-ITEM(WS-I) = L-ITEM
                 MOVE 1 TO L-FOUND L-LOVE
             END-IF
         END-PERFORM
         IF L-SPECIES = "bee"
             CALL "M1916-BEE-FOOD" USING L-ITEM L-FOUND
             MOVE L-FOUND TO L-LOVE
         END-IF
         IF L-SPECIES = "turtle" AND L-ITEM = "seagrass"
             MOVE 1 TO L-FOUND L-LOVE
         END-IF
         IF L-SPECIES = "wolf"
*>           wolf_food (19 section 6.1); only a tame wolf falls in love.
             CALL "M195-FOOD" USING L-SPECIES L-ITEM L-FOUND WS-HEAL
             MOVE L-FOUND TO L-LOVE
             MOVE 1 TO L-TAME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M188-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-BREEDS.
*> USING species, ok: 1 for the animals that have a food and can mate (a mule cannot: its canMate is the abstract false; 19 section 3.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-OK.
     MOVE 0 TO L-OK
     EVALUATE L-SPECIES
         WHEN "pig" WHEN "cow" WHEN "mooshroom" WHEN "sheep" WHEN "chicken" WHEN "horse" WHEN "donkey" WHEN "llama"
         WHEN "camel" WHEN "rabbit" WHEN "goat" WHEN "fox" WHEN "panda" WHEN "bee" WHEN "turtle" WHEN "wolf"
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM M188-BREEDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-FEED.
*> USING age, in love, found, fixed seconds, can fall in love, action out, seconds out: Animal.mobInteract with a food item (8.1). The love branch comes first: age 0, not in
*> love and able to fall in love (action 1). Otherwise a baby (negative age) is aged up (action 2) by the fixed seconds of the food, or by (remaining ticks / 20) x 0.1
*> seconds, truncated. Anything else does nothing (action 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHOLE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-LOVE                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-FIXED                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-LOVE L-FOUND L-FIXED L-CAN L-ACTION L-SECONDS.
     MOVE 0 TO L-ACTION L-SECONDS
     IF L-FOUND = 1
         EVALUATE TRUE
             WHEN L-AGE = 0 AND L-LOVE <= 0 AND L-CAN = 1
                 MOVE 1 TO L-ACTION
             WHEN L-AGE < 0
                 MOVE 2 TO L-ACTION
                 MOVE L-FIXED TO L-SECONDS
                 IF L-FIXED = 0
                     COMPUTE WS-WHOLE = - L-AGE
                     DIVIDE WS-WHOLE BY 20 GIVING WS-WHOLE
                     COMPUTE L-SECONDS = WS-WHOLE * 0.1
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM M188-FEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-AGE-UP.
*> USING age (changed), seconds, forced (changed): ageUp (8.1): a baby's age moves toward 0 by seconds x 20 and stops at 0; the forced-age effect (happy villager particles
*> every 4 ticks) lasts 40 ticks. An adult is not changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-FORCED               BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-SECONDS L-FORCED.
     IF L-AGE < 0
         COMPUTE L-AGE = FUNCTION MIN(L-AGE + L-SECONDS * 20, 0)
         MOVE 40 TO L-FORCED
     END-IF
     GOBACK.
 END PROGRAM M188-AGE-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-TICK.
*> USING age, in love, locked, forced, grown out: one tick of AgeableMob.aiStep (a baby's age counts up and the mob grows up at 0 (grown 1); a positive age is the breeding
*> cooldown and counts down unless the age is locked) and Animal.aiStep (a mob whose age is not 0 is not in love; love counts down), and the forced-age timer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-LOVE                 BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-FORCED               BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-LOVE L-LOCKED L-FORCED L-GROWN.
     MOVE 0 TO L-GROWN
     EVALUATE TRUE
         WHEN L-AGE < 0
             ADD 1 TO L-AGE
             IF L-AGE = 0
                 MOVE 1 TO L-GROWN
             END-IF
         WHEN L-AGE > 0 AND L-LOCKED = 0
             SUBTRACT 1 FROM L-AGE
     END-EVALUATE
     IF L-AGE NOT = 0
         MOVE 0 TO L-LOVE
     END-IF
     IF L-LOVE > 0
         SUBTRACT 1 FROM L-LOVE
     END-IF
     IF L-FORCED > 0
         SUBTRACT 1 FROM L-FORCED
     END-IF
     GOBACK.
 END PROGRAM M188-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-CAN-MATE.
*> USING species a, species b, love a, love b, ok: canMate (8.1): both in love and of the same class; a horse and a donkey are partners of each other (19 section 3.5); a species
*> that cannot breed (a mule) never mates.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BREEDS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    PIC X(24).
 01 L-B                    PIC X(24).
 01 L-LOVE-A               BINARY-LONG.
 01 L-LOVE-B               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-LOVE-A L-LOVE-B L-OK.
     MOVE 0 TO L-OK
     IF L-LOVE-A > 0 AND L-LOVE-B > 0
         CALL "M188-BREEDS" USING L-A WS-BREEDS
         EVALUATE TRUE
             WHEN L-A = L-B
                 MOVE WS-BREEDS TO L-OK
             WHEN L-A = "horse" AND L-B = "donkey"
                 MOVE 1 TO L-OK
             WHEN L-A = "donkey" AND L-B = "horse"
                 MOVE 1 TO L-OK
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM M188-CAN-MATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-OFFSPRING.
*> USING species a, species b, key out: getBreedOffspring (8.1, 19 section 3.5): a horse and a donkey have a mule; every other pair has the species of the first parent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-A                    PIC X(24).
 01 L-B                    PIC X(24).
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-A L-B L-KEY.
     MOVE L-A TO L-KEY
     IF (L-A = "horse" AND L-B = "donkey") OR (L-A = "donkey" AND L-B = "horse")
         MOVE "mule" TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM M188-OFFSPRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-COLOR-KEY.
*> USING colour (the dye id 0 to 15), key out: the wool item of that colour (white_wool ... black_wool), spaces for an id outside 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(11) VALUE "white      ".
    05 FILLER PIC X(11) VALUE "orange     ".
    05 FILLER PIC X(11) VALUE "magenta    ".
    05 FILLER PIC X(11) VALUE "light_blue ".
    05 FILLER PIC X(11) VALUE "yellow     ".
    05 FILLER PIC X(11) VALUE "lime       ".
    05 FILLER PIC X(11) VALUE "pink       ".
    05 FILLER PIC X(11) VALUE "gray       ".
    05 FILLER PIC X(11) VALUE "light_gray ".
    05 FILLER PIC X(11) VALUE "cyan       ".
    05 FILLER PIC X(11) VALUE "purple     ".
    05 FILLER PIC X(11) VALUE "blue       ".
    05 FILLER PIC X(11) VALUE "brown      ".
    05 FILLER PIC X(11) VALUE "green      ".
    05 FILLER PIC X(11) VALUE "red        ".
    05 FILLER PIC X(11) VALUE "black      ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME               PIC X(11) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-COLOR L-KEY.
     MOVE SPACES TO L-KEY
     IF L-COLOR >= 0 AND L-COLOR <= 15
         STRING WS-NAME(L-COLOR + 1) DELIMITED BY SPACE "_wool" DELIMITED BY SIZE INTO L-KEY
     END-IF
     GOBACK.
 END PROGRAM M188-COLOR-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SPECIES-KEY.
*> USING row, key out (PIC X(24)): the SM-KEY of a standard mob row, spaces for any other row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-KEY.
     MOVE SPACES TO L-KEY
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         MOVE SM-KEY(WS-M) TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM MOB-SPECIES-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-DATA-VALUES.
*> USING row, baby out, wool out, needed out: what an animal row sends as entity data (9.3, 19 section 1.3): metadata 16 is the baby flag of an ageable mob (EN-VARIANT 1) and
*> metadata 18 the byte of a sheep (colour, +16 sheared); a tame wolf also sends 18 (tamable flags) and 19 (owner), MOB-DATA-BUILD. The zombie family's baby flag is sent by STDMOB-VARIANT-BUILD, so only passive rows count here. needed is 1 when
*> either value differs from the default (not baby, byte 0); wool is -1 for a row that is no sheep.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-VK-TYPE             BINARY-LONG.
 01 WS-VK-PROF             BINARY-LONG.
 01 WS-VK-LEVEL            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-WOOL                 BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BABY L-WOOL L-NEEDED.
     MOVE 0 TO L-BABY L-NEEDED
     MOVE -1 TO L-WOOL
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF SM-KIND(WS-M) = 0
             IF EN-VARIANT(L-ROW) = 1
                 MOVE 1 TO L-BABY L-NEEDED
             END-IF
*>           Age locked (21 Appendix A, index 17 BOOLEAN of every ageable mob): sent once a golden dandelion locked the age (default false).
             IF EN-LOCKED(L-ROW) = 1 AND SM-KEY(WS-M) NOT = "tadpole"
                 MOVE 1 TO L-NEEDED
             END-IF
*>           Mooshroom: the type, 0 red or 1 brown (index 18 INT).
             IF SM-KEY(WS-M) = "mooshroom" AND EN-WOOL(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "sheep"
                 MOVE EN-WOOL(L-ROW) TO L-WOOL
                 IF L-WOOL > 0
                     MOVE 1 TO L-NEEDED
                 END-IF
             END-IF
             IF (SM-KEY(WS-M) = "wolf" OR "parrot" OR "cat" OR "ocelot") AND EN-TAMED(L-ROW) = 1
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "parrot" AND EN-WOOL(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "turtle" AND (EN-TURTLE-EGG(L-ROW) = 1 OR EN-TURTLE-LAY(L-ROW) > 0)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "goat" AND EN-WOOL(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "armadillo" AND EN-ARMA(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "sniffer" AND EN-SNIF(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "llama" AND (EN-STRENGTH(L-ROW) > 0 OR EN-WOOL(L-ROW) > 0)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "copper_golem"
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "rabbit" AND EN-WOOL(L-ROW) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "polar_bear" AND EN-POLAR-STAND(L-ROW) = 1
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "allay" AND (EN-ALLAY-DUP(L-ROW) > 0 OR EN-ALLAY-DANCE(L-ROW) = 1)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "fox" AND (EN-WOOL(L-ROW) > 0 OR EN-FOX-TRUST-A(L-ROW) NOT = SPACES OR EN-FOX-TRUST-B(L-ROW) NOT = SPACES
                     OR EN-FOX-FLAGS(L-ROW) > 0)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "panda" AND (EN-GENE-MAIN(L-ROW) > 0 OR EN-GENE-HIDDEN(L-ROW) > 0 OR EN-PANDA-SNEEZE(L-ROW) > 0
                     OR EN-PANDA-FLAGS(L-ROW) > 0 OR EN-PANDA-EAT(L-ROW) > 0)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "strider" AND (EN-COLD(L-ROW) = 1 OR EN-BOOST(L-ROW) > 0)
                 MOVE 1 TO L-NEEDED
             END-IF
             IF SM-KEY(WS-M) = "bee"
*>               The flags byte of a bee (19 section 16): 2 rolling, 4 stung, 8 nectar.
                 COMPUTE L-WOOL = 2 * EN-BEE-ROLL(L-ROW) + 4 * EN-BEE-STUNG(L-ROW) + 8 * EN-BEE-NECTAR(L-ROW)
                 IF L-WOOL > 0
                     MOVE 1 TO L-NEEDED
                 END-IF
             END-IF
         END-IF
     END-IF
*>   The nautilus family (44-7 section 10.2): tame, dash and the zombie nautilus variant are entity data too.
     IF WS-M > 0
         CALL "NAUTILUS-NEEDED" USING L-ROW L-NEEDED
     END-IF
*>   The tadpole is a water animal (kind 2): its lock is sent too (19 section 11.2).
     IF WS-M > 0
         IF SM-KEY(WS-M) = "villager"
             CALL "VILLOOK-CODE" USING L-ROW WS-VK-TYPE WS-VK-PROF WS-VK-LEVEL
             IF WS-VK-TYPE NOT = 2 OR WS-VK-PROF NOT = 0 OR WS-VK-LEVEL NOT = 1
                 MOVE 1 TO L-NEEDED
             END-IF
         END-IF
     END-IF
     IF WS-M > 0
         IF (SM-KEY(WS-M) = "tadpole" AND EN-LOCKED(L-ROW) = 1) OR (SM-KEY(WS-M) = "frog" AND EN-TONGUE(L-ROW) > 0)
             MOVE 1 TO L-NEEDED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-DATA-VALUES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-DATA-BUILD.
*> USING row, PB-BUFFER: Set Entity Data (0x65) with the entries of MOB-DATA-VALUES that differ from the default: index 16 BOOLEAN (baby), index 18 BYTE (sheep wool).
*> A tame wolf sends index 18 BYTE (M188-TAME-FLAGS: tame and sitting) and index 19 OPTIONAL_LIVING_ENTITY_REFERENCE (the owner's UUID), 18 section 8.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-KEY                 PIC X(24).
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TAME-ONE            BINARY-LONG VALUE 1.
 01 WS-SERIALIZER-BYTE     BINARY-LONG VALUE 0.
 01 WS-SERIALIZER-OWNER    BINARY-LONG VALUE 13.
 01 WS-SERIALIZER-INT      BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "copper_golem"
*>       Index 16 is the weathering state of a copper golem, not a baby flag (19 section 21).
         CALL "CG-DATA-BUILD" USING L-ROW PB-BUFFER
         GOBACK
     END-IF
     CALL "MOB-DATA-VALUES" USING L-ROW WS-BABY WS-WOOL WS-NEEDED
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 16 TO MD-MD-INDEX
     MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
     MOVE WS-BABY TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     IF WS-WOOL >= 0
         MOVE 18 TO MD-MD-INDEX
         MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
         MOVE WS-WOOL TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF EN-LOCKED(L-ROW) = 1 AND WS-KEY NOT = "tadpole"
         INITIALIZE MD-METADATA-ENTRY
         MOVE 17 TO MD-MD-INDEX
         MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
         MOVE 1 TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     IF WS-KEY = "mooshroom" AND EN-WOOL(L-ROW) > 0
         INITIALIZE MD-METADATA-ENTRY-X
         MOVE 18 TO MD-MX-INDEX
         MOVE WS-SERIALIZER-INT TO MD-MX-SERIALIZER
         MOVE EN-WOOL(L-ROW) TO MD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     END-IF
     IF (WS-KEY = "wolf" OR "parrot" OR "cat") AND EN-TAMED(L-ROW) = 1
         CALL "M188-TAME-FLAGS" USING WS-TAME-ONE EN-SIT(L-ROW) WS-FLAGS
         INITIALIZE MD-METADATA-ENTRY-X
         MOVE 18 TO MD-MX-INDEX
         MOVE WS-SERIALIZER-BYTE TO MD-MX-SERIALIZER
         MOVE WS-FLAGS TO MD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
         INITIALIZE MD-METADATA-ENTRY-X
         MOVE 19 TO MD-MX-INDEX
         MOVE WS-SERIALIZER-OWNER TO MD-MX-SERIALIZER
         MOVE 1 TO MD-MX-PRESENT
         MOVE EN-OWNER-UUID(L-ROW) TO MD-MX-UUID
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     END-IF
     IF WS-KEY = "parrot" AND EN-WOOL(L-ROW) > 0
         INITIALIZE MD-METADATA-ENTRY-X
         MOVE 20 TO MD-MX-INDEX
         MOVE WS-SERIALIZER-INT TO MD-MX-SERIALIZER
         MOVE EN-WOOL(L-ROW) TO MD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     END-IF
*>   A strider: index 18 INT the boost total, index 19 BOOLEAN suffocating (21 section 5.7).
     IF WS-KEY = "strider" AND EN-BOOST(L-ROW) > 0
         INITIALIZE MD-METADATA-ENTRY-X
         MOVE 18 TO MD-MX-INDEX
         MOVE WS-SERIALIZER-INT TO MD-MX-SERIALIZER
         MOVE EN-BOOST(L-ROW) TO MD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     END-IF
     IF WS-KEY = "strider" AND EN-COLD(L-ROW) = 1
         INITIALIZE MD-METADATA-ENTRY
         MOVE 19 TO MD-MD-INDEX
         MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
         MOVE 1 TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     CALL "MOB-CARE-DATA" USING L-ROW PB-BUFFER
     CALL "MOB-RABBIT-DATA" USING L-ROW PB-BUFFER
     CALL "MOB-EQUINE-DATA" USING L-ROW PB-BUFFER
     CALL "NAUTILUS-DATA" USING L-ROW PB-BUFFER
     CALL "MOB-POLAR-DATA" USING L-ROW PB-BUFFER
     CALL "VILLOOK-DATA" USING L-ROW PB-BUFFER
     CALL "VL-SLEEP-DATA" USING L-ROW PB-BUFFER
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM MOB-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-DATA-SEND.
*> USING row: MOB-DATA-BUILD to every player whose client has the row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING L-ROW PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-DATA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-BORN.
*> USING row: the first state of a new mob (19 sections 2.4 and 2.5): a sheep gets its spawn colour (M19-SHEEP-COLOR, the configuration by the biome tags), a chicken its egg timer
*> 6000 + nextInt(6000); the variant of a wolf, frog, fox, pig, cow and chicken follows the biome of the cell (1.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-CONFIG              BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SALT-W              BINARY-LONG VALUE 21.
 01 WS-SALT-C              BINARY-LONG VALUE 22.
 01 WS-SALT-E              BINARY-LONG VALUE 23.
 01 WS-BOUND-W             BINARY-LONG VALUE 100.
 01 WS-BOUND-C             BINARY-LONG VALUE 500.
 01 WS-BOUND-E             BINARY-LONG VALUE 6000.
 01 WS-SALT-P              BINARY-LONG VALUE 43.
 01 WS-BOUND-P             BINARY-LONG VALUE 5.
 01 WS-SALT-S              BINARY-LONG VALUE 53.
 01 WS-SALT-GS             BINARY-LONG VALUE 54.
 01 WS-SALT-GH             BINARY-LONG VALUE 55.
 01 WS-SALT-GC             BINARY-LONG VALUE 56.
 01 WS-BOUND-GS            BINARY-LONG VALUE 50.
 01 WS-BOUND-GH            BINARY-LONG VALUE 10.
 01 WS-BOUND-GC            BINARY-LONG VALUE 2.
 01 WS-DRAW-G              BINARY-LONG.
 01 WS-VL-VILLAGER         BINARY-LONG VALUE 1.
 01 WS-VL-TRADER           BINARY-LONG VALUE 2.
 01 WS-VL-PLAINS           BINARY-LONG VALUE 2.
 01 WS-VL-SLOT             BINARY-LONG.
 01 WS-BOUND-S             BINARY-LONG VALUE 6000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-BIOME               PIC X(48).
 01 WS-TAGS                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-COLD-FROG           BINARY-LONG.
 01 WS-WARM-FROG           BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-SALT-V              BINARY-LONG VALUE 57.
 01 WS-BOUND-V             BINARY-LONG VALUE 2.
 01 WS-DRAW-V              BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-BRIGHT              FLOAT-LONG.
 01 WS-SLIME-CH            FLOAT-LONG.
 01 WS-MOONFLAG            BINARY-LONG.
 01 WS-HUTFLAG             BINARY-LONG VALUE 0.
 01 WS-SALT-CAT            BINARY-LONG VALUE 58.
 01 WS-BOUND-CAT           BINARY-LONG VALUE 110.
 01 WS-DRAW-CAT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
*>   The biome of the spawn cell picks the variant (19 section 1.6): the tags for farm animals, frogs and foxes; the wolf by its own table. A column that is not loaded has no biome.
     COMPUTE WS-IX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-IY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-IZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "M19-BIOME-KEY-AT" USING EN-DIM(L-ROW) WS-IX WS-IY WS-IZ WS-BIOME
     CALL "M19-BIOME-FLAGS" USING WS-BIOME WS-TAGS
     MOVE FUNCTION MOD(WS-TAGS, 2) TO WS-COLD
     COMPUTE WS-Q = WS-TAGS / 2
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-WARM
     COMPUTE WS-Q = WS-TAGS / 4
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-COLD-FROG
     COMPUTE WS-Q = WS-TAGS / 8
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-WARM-FROG
     COMPUTE WS-Q = WS-TAGS / 16
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-SNOW
     EVALUATE WS-KEY
         WHEN "wolf"
             CALL "M19-WOLF-VARIANT" USING WS-BIOME EN-WOOL(L-ROW)
         WHEN "frog"
*>           cold has priority 1 with the warm tag never overlapping it; temperate (0) otherwise.
             COMPUTE EN-WOOL(L-ROW) = WS-COLD-FROG + 2 * WS-WARM-FROG
         WHEN "fox"
             MOVE WS-SNOW TO EN-WOOL(L-ROW)
             CALL "FOX-BORN" USING L-ROW
         WHEN "pig"
         WHEN "cow"
             CALL "XP-RANDOM" USING WS-SALT-V WS-BOUND-V WS-DRAW-V
             CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW-V EN-WOOL(L-ROW)
         WHEN "sheep"
             MOVE 0 TO WS-CONFIG
             IF WS-COLD = 1
                 MOVE 2 TO WS-CONFIG
             END-IF
             IF WS-WARM = 1
                 MOVE 1 TO WS-CONFIG
             END-IF
             CALL "XP-RANDOM" USING WS-SALT-W WS-BOUND-W WS-W
             CALL "XP-RANDOM" USING WS-SALT-C WS-BOUND-C WS-C
             CALL "M19-SHEEP-COLOR" USING WS-CONFIG WS-W WS-C EN-WOOL(L-ROW)
         WHEN "chicken"
             CALL "XP-RANDOM" USING WS-SALT-V WS-BOUND-V WS-DRAW-V
             CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW-V EN-WOOL(L-ROW)
             CALL "XP-RANDOM" USING WS-SALT-E WS-BOUND-E WS-DRAW
             COMPUTE EN-EGG(L-ROW) = 6000 + WS-DRAW
         WHEN "parrot"
             CALL "XP-RANDOM" USING WS-SALT-P WS-BOUND-P EN-WOOL(L-ROW)
         WHEN "goat"
*>           Screaming with chance 2 percent; an adult loses one horn, left or right 50/50, with chance 10 percent (19 section 10). EN-WOOL: 1 screaming, 2 no left horn, 4 no right horn.
             CALL "XP-RANDOM" USING WS-SALT-GS WS-BOUND-GS WS-DRAW-G
             IF WS-DRAW-G = 0
                 MOVE 1 TO EN-WOOL(L-ROW)
             END-IF
             CALL "XP-RANDOM" USING WS-SALT-GH WS-BOUND-GH WS-DRAW-G
             IF WS-DRAW-G = 0
                 CALL "XP-RANDOM" USING WS-SALT-GC WS-BOUND-GC WS-DRAW-G
                 COMPUTE EN-WOOL(L-ROW) = EN-WOOL(L-ROW) + 2 + 2 * WS-DRAW-G
             END-IF
         WHEN "cat"
*>           The cat variant (19 section 1.6): the moon brightness of the overworld clock decides whether all_black joins the pool (the swamp hut structure test is not known here).
             COMPUTE WS-TOTAL = FUNCTION MOD(CW-TIME, 192000)
             CALL "WC-MOON" USING WS-TOTAL WS-PHASE WS-BRIGHT WS-SLIME-CH
             MOVE 0 TO WS-MOONFLAG
             IF WS-BRIGHT >= 0.9
                 MOVE 1 TO WS-MOONFLAG
             END-IF
             CALL "XP-RANDOM" USING WS-SALT-CAT WS-BOUND-CAT WS-DRAW-CAT
             CALL "M44-CAT-VARIANT" USING WS-MOONFLAG WS-HUTFLAG WS-DRAW-CAT EN-WOOL(L-ROW)
         WHEN "rabbit"
             CALL "RABBIT-BORN" USING L-ROW
         WHEN "armadillo"
*>           scuteTime: nextInt(6000) + 6000 (19 section 13).
             CALL "XP-RANDOM" USING WS-SALT-S WS-BOUND-S WS-DRAW
             COMPUTE EN-SCUTE(L-ROW) = 6000 + WS-DRAW
         WHEN "bat"
*>           A new bat hangs (Bat constructor, 21 section 8.10): EN-PH-PHASE 1 is the resting flag.
             MOVE 1 TO EN-PH-PHASE(L-ROW)
         WHEN "llama"
             CALL "LLAMA-BORN" USING L-ROW
         WHEN "trader_llama"
             CALL "LLAMA-BORN" USING L-ROW
         WHEN "horse"
             CALL "M44-HORSE-BORN" USING L-ROW
             CALL "M19-EQUINE-BORN" USING L-ROW
         WHEN "donkey"
         WHEN "mule"
             CALL "M19-EQUINE-BORN" USING L-ROW
         WHEN "panda"
             CALL "PANDA-BORN" USING L-ROW
         WHEN "wandering_trader"
*>           The trader state (19 section 23): kind 2 builds the three trade sets at once.
             CALL "VL-SETUP" USING EN-ID(L-ROW) WS-VL-TRADER WS-VL-PLAINS WS-VL-SLOT
         WHEN "villager"
*>           The villager state (19 section 22; the type follows the biome of the position, 22.1).
             CALL "VL-BIOME-TYPE-AT" USING L-ROW WS-VL-PLAINS
             CALL "VL-SETUP" USING EN-ID(L-ROW) WS-VL-VILLAGER WS-VL-PLAINS WS-VL-SLOT
         WHEN "turtle"
*>           The home of a turtle is the block it spawned in (19 section 12).
             MOVE 1 TO EN-HOME-SET(L-ROW)
             COMPUTE EN-HOME-X(L-ROW) = FUNCTION INTEGER(EN-X(L-ROW))
             COMPUTE EN-HOME-Y(L-ROW) = FUNCTION INTEGER(EN-Y(L-ROW))
             COMPUTE EN-HOME-Z(L-ROW) = FUNCTION INTEGER(EN-Z(L-ROW))
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PARTNER.
*> USING row, partner out: BreedGoal.findNearestPartner (8.1): the nearest other animal of its dimension that is alive, not panicking, tamed when the species needs it, and that the animal
*> can mate with, within 8 blocks (squared distance 64); 0 when there is none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-OTHER               PIC X(24).
 01 WS-OK                  BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-LOVE-A              BINARY-LONG.
 01 WS-LOVE-B              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PARTNER              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PARTNER.
     MOVE 0 TO L-PARTNER
     MOVE 64 TO WS-BEST
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
                 AND EN-FLEE(WS-E) = 0 AND EN-PLAYER(WS-E) = 0
             CALL "MOB-SPECIES-KEY" USING WS-E WS-OTHER
             MOVE EN-LOVE(L-ROW) TO WS-LOVE-A
             MOVE EN-LOVE(WS-E) TO WS-LOVE-B
             CALL "M188-CAN-MATE" USING WS-KEY WS-OTHER WS-LOVE-A WS-LOVE-B WS-OK
             MOVE 0 TO WS-HORSE
             IF WS-KEY = "horse" OR "donkey" OR "llama" OR "camel" OR "wolf"
                 COMPUTE WS-HORSE = 1 - EN-TAMED(L-ROW) * EN-TAMED(WS-E)
             END-IF
             IF WS-KEY = "wolf" AND (EN-SIT(L-ROW) = 1 OR EN-SIT(WS-E) = 1)
                 MOVE 1 TO WS-HORSE
             END-IF
             IF WS-OK = 1 AND WS-HORSE = 0
                 COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                 COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-D2 <= WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE WS-E TO L-PARTNER
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-PARTNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-BREED.
*> USING row a, row b: Animal.spawnChildFromBreeding and finalizeSpawnChildFromBreeding (8.1): the baby of M188-OFFSPRING at the first parent's position with yaw 0, age -24000 and the
*> baby flag; both parents get age 6000 (the 5-minute cooldown), lose love and partner; Entity Event 18 (hearts) goes to the viewers of the first parent; one experience orb
*> of 1 + nextInt(7) points appears at it. The baby of two sheep has M19-SHEEP-MIX's colour, of two mooshrooms M19-MOOSHROOM-BREED's type, otherwise the colour or variant
*> of a parent by a coin. The animals_bred statistic and the mob_drops game rule are not modelled yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 18.
 01 WS-KEY-A               PIC X(24).
 01 WS-KEY-B               PIC X(24).
 01 WS-KEY                 PIC X(24).
 01 WS-FULL                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-COIN                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SALT-COIN           BINARY-LONG VALUE 24.
 01 WS-SALT-DRAW           BINARY-LONG VALUE 25.
 01 WS-SALT-XP             BINARY-LONG VALUE 26.
 01 WS-BOUND-2             BINARY-LONG VALUE 2.
 01 WS-BOUND-1024          BINARY-LONG VALUE 1024.
 01 WS-BOUND-7             BINARY-LONG VALUE 7.
 01 WS-SALT-GK             BINARY-LONG VALUE 57.
 01 WS-BOUND-GK            BINARY-LONG VALUE 50.
 01 WS-DRAW-K              BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-COLOR-A             BINARY-LONG.
 01 WS-COLOR-B             BINARY-LONG.
 01 WS-CHILD-COLOR         BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B.
     CALL "MOB-SPECIES-KEY" USING L-A WS-KEY-A
     CALL "MOB-SPECIES-KEY" USING L-B WS-KEY-B
     IF WS-KEY-A = "turtle"
*>       Two turtles make no baby: the first one gets the egg (19 section 12).
         MOVE 1 TO EN-TURTLE-EGG(L-A)
         CALL "MOB-DATA-SEND" USING L-A
         CALL "MOB-BREED-DONE" USING L-A L-B
         GOBACK
     END-IF
     CALL "M188-OFFSPRING" USING WS-KEY-A WS-KEY-B WS-KEY
     MOVE SPACES TO WS-FULL
     STRING "minecraft:" DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-FULL
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE EN-DIM(L-A) TO WS-DIM
     MOVE EN-X(L-A) TO WS-X
     MOVE EN-Y(L-A) TO WS-Y
     MOVE EN-Z(L-A) TO WS-Z
     MOVE EN-ID(L-A) TO WS-ID
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BABY
     MOVE -24000 TO EN-MOBAGE(WS-BABY)
     MOVE 1 TO EN-VARIANT(WS-BABY)
     CALL "XP-RANDOM" USING WS-SALT-COIN WS-BOUND-2 WS-COIN
     CALL "XP-RANDOM" USING WS-SALT-DRAW WS-BOUND-1024 WS-DRAW
     MOVE EN-WOOL(L-A) TO WS-COLOR-A
     MOVE EN-WOOL(L-B) TO WS-COLOR-B
     EVALUATE WS-KEY
         WHEN "llama"
             CALL "LLAMA-BRED" USING L-A L-B WS-BABY WS-COIN
         WHEN "rabbit"
             CALL "RABBIT-BRED" USING L-A L-B WS-BABY WS-COIN
         WHEN "fox"
             CALL "FOX-BRED" USING L-A L-B WS-BABY WS-COIN
         WHEN "panda"
             CALL "PANDA-BRED" USING L-A L-B WS-BABY
         WHEN "wolf"
             CALL "WOLF-BRED" USING L-A L-B WS-BABY WS-COIN
         WHEN "cat"
             CALL "CAT-BRED" USING L-A L-B WS-BABY WS-COIN
         WHEN "sheep"
             COMPUTE WS-COLOR-A = FUNCTION MOD(EN-WOOL(L-A), 16)
             COMPUTE WS-COLOR-B = FUNCTION MOD(EN-WOOL(L-B), 16)
             CALL "M19-SHEEP-MIX" USING WS-COLOR-A WS-COLOR-B WS-COIN WS-CHILD-COLOR
             MOVE WS-CHILD-COLOR TO EN-WOOL(WS-BABY)
         WHEN "goat"
*>           The kid has both horns; it screams when the parent chosen by the coin screams or by the 2 percent roll (19 section 10).
             CALL "XP-RANDOM" USING WS-SALT-GK WS-BOUND-GK WS-DRAW-K
             MOVE 0 TO EN-WOOL(WS-BABY)
             IF FUNCTION MOD(WS-COLOR-A, 2) = 1 AND WS-COIN = 0
                 MOVE 1 TO EN-WOOL(WS-BABY)
             END-IF
             IF FUNCTION MOD(WS-COLOR-B, 2) = 1 AND WS-COIN = 1
                 MOVE 1 TO EN-WOOL(WS-BABY)
             END-IF
             IF WS-DRAW-K = 0
                 MOVE 1 TO EN-WOOL(WS-BABY)
             END-IF
         WHEN "mooshroom"
             CALL "M19-MOOSHROOM-BREED" USING WS-COLOR-A WS-COLOR-B WS-DRAW WS-COIN WS-CHILD-COLOR
             MOVE WS-CHILD-COLOR TO EN-WOOL(WS-BABY)
         WHEN OTHER
             IF WS-COIN = 0
                 MOVE WS-COLOR-A TO EN-WOOL(WS-BABY)
             ELSE
                 MOVE WS-COLOR-B TO EN-WOOL(WS-BABY)
             END-IF
     END-EVALUATE
     CALL "MOB-DATA-SEND" USING WS-BABY
     CALL "MOB-BREED-DONE" USING L-A L-B
     GOBACK.
 END PROGRAM MOB-BREED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-BREED-DONE.
*> USING row a, row b: the end of a breeding (8.1): both parents get age 6000 and lose love and partner, Entity Event 18 (hearts) goes to the viewers of the first parent and one
*> experience orb of 1 + nextInt(7) points appears at it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 18.
 01 WS-SALT-XP             BINARY-LONG VALUE 26.
 01 WS-BOUND-7             BINARY-LONG VALUE 7.
 01 WS-POINTS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B.
     MOVE EN-DIM(L-A) TO WS-DIM
     MOVE EN-X(L-A) TO WS-X
     MOVE EN-Y(L-A) TO WS-Y
     MOVE EN-Z(L-A) TO WS-Z
     MOVE 6000 TO EN-MOBAGE(L-A) EN-MOBAGE(L-B)
     MOVE 0 TO EN-LOVE(L-A) EN-LOVE(L-B) EN-LOVE-PARTNER(L-A) EN-LOVE-PARTNER(L-B) EN-LOVE-TIME(L-A) EN-LOVE-TIME(L-B)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-A) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-A PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "XP-RANDOM" USING WS-SALT-XP WS-BOUND-7 WS-POINTS
     ADD 1 TO WS-POINTS
     CALL "XP-AWARD" USING WS-DIM WS-X WS-Y WS-Z WS-POINTS
     GOBACK.
 END PROGRAM MOB-BREED-DONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SHEEP-EAT-START.
*> USING row, draw: the EatBlock goal of a sheep (19 section 2.4): it starts when the draw is 0 (the caller draws below M19-SHEEP-EAT-BOUND: 1000 for an adult, 50 for a baby) and the block at the
*> feet is edible_for_sheep (short grass, short dry grass, tall dry grass, fern) or the block below is a grass block: the timer is 40 ticks and Entity Event 10 goes to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 10.
 01 WS-KEY-FEET            PIC X(48).
 01 WS-KEY-BELOW           PIC X(48).
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DRAW.
     IF L-DRAW = 0
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         COMPUTE WS-BELOW = WS-BY - 1
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-BLOCK) TO WS-KEY-FEET
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-STATE
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-BLOCK) TO WS-KEY-BELOW
         IF WS-KEY-FEET = "short_grass" OR "short_dry_grass" OR "tall_dry_grass" OR "fern" OR WS-KEY-BELOW = "grass_block"
             MOVE 40 TO EN-EAT(L-ROW)
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-SHEEP-EAT-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SHEEP-EAT-TICK.
*> USING row: one tick of the eating timer (19 section 2.4). At 4 the sheep eats (M19-SHEEP-EAT-STEP with the mob-griefing rule taken as true: it is not modelled yet): a plant at
*> the feet is destroyed, or the grass block below becomes dirt; then it has eaten (M19-SHEEP-ATE: the wool regrows, a baby ages up 60 ticks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-KEY-FEET            PIC X(48).
 01 WS-KEY-BELOW           PIC X(48).
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EDIBLE              BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-GRIEFING            BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DIRT-KEY            PIC X(112) VALUE "minecraft:dirt".
 01 WS-DIRT-BLOCK          BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-DIRT                BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-EAT(L-ROW) > 0
         SUBTRACT 1 FROM EN-EAT(L-ROW)
         IF EN-EAT(L-ROW) = 4
             COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
             COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
             COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
             COMPUTE WS-BELOW = WS-BY - 1
             CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
             MOVE CB-KEY(WS-BLOCK) TO WS-KEY-FEET
             CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-STATE
             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
             MOVE CB-KEY(WS-BLOCK) TO WS-KEY-BELOW
             MOVE 0 TO WS-EDIBLE WS-GRASS
             IF WS-KEY-FEET = "short_grass" OR "short_dry_grass" OR "tall_dry_grass" OR "fern"
                 MOVE 1 TO WS-EDIBLE
             END-IF
             IF WS-KEY-BELOW = "grass_block"
                 MOVE 1 TO WS-GRASS
             END-IF
             CALL "M19-SHEEP-EAT-STEP" USING WS-EDIBLE WS-GRASS WS-GRIEFING WS-ACTION
             EVALUATE WS-ACTION
                 WHEN 1
                     CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-AIR
                 WHEN 2
                     CALL "CONTENT-BLOCK-BY-KEY" USING WS-DIRT-KEY WS-DIRT-BLOCK WS-BLOCK-ROW WS-STATUS
                     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
                     COMPUTE WS-DIRT = FUNCTION NUMVAL(WS-STATE-TEXT)
                     CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-DIRT
             END-EVALUATE
             MOVE EN-VARIANT(L-ROW) TO WS-BABY
             CALL "M19-SHEEP-ATE" USING EN-WOOL(L-ROW) WS-BABY EN-MOBAGE(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-SHEEP-EAT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LIFE-TICK.
*> USING row, hx out, hz out, walk out: one tick of the life of a passive mob (8.1): its age and love (M188-TICK), the baby that grows up (the baby flag goes to the viewers),
*> a chicken's egg timer (19 section 2.5), a sheep's eating, and the BreedGoal: an animal in love picks its nearest partner (MOB-PARTNER), walks to it at its walking speed
*> for the ticks of loveTime and, with loveTime at 60 and the partner within 3 blocks, breeds (MOB-BREED). A panicking animal does not walk to a partner. walk is 1 when hx and
*> hz are the walk of this tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-KEY                 PIC X(24).
 01 WS-OTHER               PIC X(24).
 01 WS-M                   BINARY-LONG.
 01 WS-GROWN               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LAID                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-SALT-EGG            BINARY-LONG VALUE 27.
 01 WS-SALT-EAT            BINARY-LONG VALUE 28.
 01 WS-BOUND-EGG           BINARY-LONG VALUE 6000.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-EGG-KEY             PIC X(24).
 01 WS-EGG-FULL            PIC X(112).
 01 WS-EGG-ITEM            BINARY-LONG.
 01 WS-EGG-ROW             PIC X(270).
 01 WS-EV-PLACE            PIC X(32) VALUE "entity_place".
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-LOVE-A              BINARY-LONG.
 01 WS-LOVE-B              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     CALL "M188-TICK" USING EN-MOBAGE(L-ROW) EN-LOVE(L-ROW) EN-LOCKED(L-ROW) EN-FORCED(L-ROW) WS-GROWN
     IF WS-GROWN = 1
         MOVE 0 TO EN-VARIANT(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
         IF WS-KEY = "turtle"
             CALL "TURTLE-GROWN" USING L-ROW
         END-IF
     END-IF
     IF WS-KEY = "chicken" AND EN-MOBAGE(L-ROW) >= 0 AND EN-VARIANT(L-ROW) = 0 AND EN-JOCKEY(L-ROW) = 0
         CALL "XP-RANDOM" USING WS-SALT-EGG WS-BOUND-EGG WS-DRAW
         CALL "M19-CHICKEN-EGG-TICK" USING EN-EGG(L-ROW) WS-DRAW WS-LAID
         IF WS-LAID = 1
             MOVE EN-WOOL(L-ROW) TO WS-VARIANT
             CALL "M19-CHICKEN-EGG-ITEM" USING WS-VARIANT WS-EGG-KEY
             MOVE SPACES TO WS-EGG-FULL
             STRING "minecraft:" DELIMITED BY SIZE WS-EGG-KEY DELIMITED BY SPACE INTO WS-EGG-FULL
             CALL "CONTENT-ITEM-BY-KEY" USING WS-EGG-FULL WS-EGG-ITEM WS-EGG-ROW WS-STATUS
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-EGG-ITEM WS-ONE
                 WS-PATCH WS-ITEM-ENTITY
*>           Chicken.aiStep: entity_place at the chicken's position, the chicken as the source (30-8 14.3.3)
             CALL "GAME-EVENT-AT" USING WS-EV-PLACE L-ROW
         END-IF
     END-IF
     IF WS-KEY = "sheep"
         IF EN-EAT(L-ROW) = 0
             MOVE EN-VARIANT(L-ROW) TO WS-BABY
             CALL "M19-SHEEP-EAT-BOUND" USING WS-BABY WS-BOUND
             CALL "XP-RANDOM" USING WS-SALT-EAT WS-BOUND WS-DRAW
             CALL "MOB-SHEEP-EAT-START" USING L-ROW WS-DRAW
         END-IF
         CALL "MOB-SHEEP-EAT-TICK" USING L-ROW
     END-IF
     IF EN-LOVE(L-ROW) = 0 OR EN-FLEE(L-ROW) > 0
         MOVE 0 TO EN-LOVE-PARTNER(L-ROW) EN-LOVE-TIME(L-ROW)
     ELSE
         IF EN-LOVE-PARTNER(L-ROW) = 0
             CALL "MOB-PARTNER" USING L-ROW WS-P
             MOVE WS-P TO EN-LOVE-PARTNER(L-ROW)
             MOVE 0 TO EN-LOVE-TIME(L-ROW)
         END-IF
         MOVE EN-LOVE-PARTNER(L-ROW) TO WS-P
         IF WS-P > 0
             CALL "MOB-SPECIES-KEY" USING WS-P WS-OTHER
             MOVE 0 TO WS-OK
             IF EN-USED(WS-P) = 1 AND EN-HEALTH(WS-P) > 0 AND EN-FLEE(WS-P) = 0
                 MOVE EN-LOVE(L-ROW) TO WS-LOVE-A
                 MOVE EN-LOVE(WS-P) TO WS-LOVE-B
                 CALL "M188-CAN-MATE" USING WS-KEY WS-OTHER WS-LOVE-A WS-LOVE-B WS-OK
             END-IF
             IF WS-OK = 0
                 MOVE 0 TO EN-LOVE-PARTNER(L-ROW) EN-LOVE-TIME(L-ROW)
             ELSE
                 ADD 1 TO EN-LOVE-TIME(L-ROW)
                 COMPUTE WS-DX = EN-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-P) - EN-Z(L-ROW)
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                 IF EN-LOVE-TIME(L-ROW) >= 60 AND WS-D2 < 9
                     CALL "MOB-BREED" USING L-ROW WS-P
                 ELSE
                     COMPUTE WS-H = FUNCTION SQRT(WS-D2)
                     COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
                     IF WS-H > 0.1
                         COMPUTE L-HX = WS-SPEED * WS-DX / WS-H
                         COMPUTE L-HZ = WS-SPEED * WS-DZ / WS-H
                         MOVE 1 TO L-WALK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-LIFE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-ITEM-ID.
*> USING key (PIC X(24), no "minecraft:"), id out: the item id of the key of the open content set (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL                PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE SPACES TO WS-FULL
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-FULL
     CALL "CONTENT-ITEM-BY-KEY" USING WS-FULL L-ID WS-ROW WS-STATUS
     GOBACK.
 END PROGRAM MOB-ITEM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TAKE.
*> USING player row: the held stack loses one item, except in creative mode (usePlayerItem); the slot goes to the client.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-MODE(L-ROW) NOT = 1
         CALL "INV-REMOVE" USING L-ROW PL-HELD(L-ROW) WS-ONE
         CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) PL-HELD(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MOB-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SWAP.
*> USING player row, item: a survival player's held item becomes that item (ItemUtils.createFilledResult): a stack of one is replaced in its slot, otherwise one is taken and the new
*> item is added to the inventory, what does not fit lands on the ground at the player. A creative player keeps the stack and gets nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM.
     IF PL-MODE(L-ROW) NOT = 1
         IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) = 1
             MOVE L-ITEM TO PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1)
             MOVE 0 TO PL-SLOT-VAR(L-ROW, PL-HELD(L-ROW) + 1)
             CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) PL-HELD(L-ROW)
         ELSE
             CALL "MOB-TAKE" USING L-ROW
             CALL "INV-ADD" USING L-ROW L-ITEM WS-ONE WS-LEFT
             PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 35
                 CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-SLOT
             END-PERFORM
             IF WS-LEFT > 0
                 CALL "IP-AT-LOCATION" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-OFFSET L-ITEM WS-LEFT
                     WS-PATCH WS-DROPPED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-DROP-ITEMS.
*> USING entity row, item key (PIC X(24)), count: count single items of that key at the entity, one block up (Entity.spawnAtLocation with the offset 1.0 of a shearing drop).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OFFSET              FLOAT-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KEY L-COUNT.
     CALL "MOB-ITEM-ID" USING L-KEY WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE WS-PATCH
             WS-DROPPED
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-DROP-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-FEED-USE.
*> USING player row, entity row: the player feeds the animal the held item (Animal.mobInteract, 8.1): M188-FOOD and M188-FEED decide. Love: one item is used, the animal is in love
*> for 600 ticks with the player as its cause and Entity Event 18 goes to the viewers. A baby: one item is used and it ages up, the forced-age timer runs and, when it reaches age 0, it
*> is no longer a baby. The horse family, llamas and camels fall in love only when tamed. The healing and temper of horse food are open items.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 18.
 01 WS-KEY                 PIC X(24).
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM                PIC X(24).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FIXED               BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-TAME                BINARY-LONG.
 01 WS-BREEDS              BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     MOVE WS-KEY48 TO WS-ITEM
     CALL "M188-FOOD" USING WS-KEY WS-ITEM WS-FOUND WS-FIXED WS-LOVE WS-TAME
     CALL "M188-BREEDS" USING WS-KEY WS-BREEDS
     MOVE WS-LOVE TO WS-CAN
     IF WS-BREEDS = 0
         MOVE 0 TO WS-CAN
     END-IF
     IF WS-TAME = 1 AND EN-TAMED(L-ENTITY) = 0
         MOVE 0 TO WS-CAN
     END-IF
     IF WS-KEY = "turtle" AND EN-TURTLE-EGG(L-ENTITY) = 1
*>       A turtle with an egg cannot fall in love (19 section 12).
         MOVE 0 TO WS-CAN
     END-IF
     CALL "M188-FEED" USING EN-MOBAGE(L-ENTITY) EN-LOVE(L-ENTITY) WS-FOUND WS-FIXED WS-CAN WS-ACTION WS-SECONDS
     EVALUATE WS-ACTION
         WHEN 1
             CALL "MOB-TAKE" USING L-ROW
             MOVE 600 TO EN-LOVE(L-ENTITY)
             MOVE L-ROW TO EN-LOVE-CAUSE(L-ENTITY)
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         WHEN 2
             CALL "MOB-TAKE" USING L-ROW
             CALL "M188-AGE-UP" USING EN-MOBAGE(L-ENTITY) WS-SECONDS EN-FORCED(L-ENTITY)
             IF EN-MOBAGE(L-ENTITY) = 0
                 MOVE 0 TO EN-VARIANT(L-ENTITY)
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-FEED-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-WOLF-USE.
*> USING player row, entity row (a wolf): the main hand on a wolf (19 section 6.1). An untamed wolf with a bone: the bone is used and nextInt(3) = 0 tames it (the player is the owner,
*> 40 health, the sit order, Entity Event 7) else Entity Event 6. A tame wolf of this player: the sit order toggles (M188-SIT-TOGGLE); the owner's dye and food are MOB-CARE-USE (mob-19-5.cob); armour is an open item.
*> The wolf's entity data goes to the viewers after a change.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-SALT                BINARY-LONG VALUE 31.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG VALUE 0.
 01 WS-WOLF-MAX            BINARY-LONG VALUE 40.
 01 WS-WOLF-MULT           BINARY-LONG VALUE 2.
 01 WS-NEW                 BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     END-IF
     IF EN-TAMED(L-ENTITY) = 0
         IF WS-KEY48 = "bone"
             CALL "MOB-TAKE" USING L-ROW
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             CALL "M188-TAME-TRY" USING WS-DRAW WS-OK
             MOVE 6 TO WS-EVENT
             IF WS-OK = 1
                 MOVE 7 TO WS-EVENT
                 MOVE 1 TO EN-TAMED(L-ENTITY) EN-SIT(L-ENTITY)
                 MOVE PL-UUID(L-ROW) TO EN-OWNER-UUID(L-ENTITY)
                 MOVE 40 TO EN-HEALTH(L-ENTITY)
             END-IF
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             IF WS-OK = 1
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
         END-IF
     ELSE
         CALL "WOLF-ARMOR-USE" USING L-ROW L-ENTITY WS-CONSUMED
         IF WS-CONSUMED = 0
             CALL "MOB-CARE-USE" USING L-ROW L-ENTITY WS-WOLF-MAX WS-WOLF-MULT WS-CONSUMED
         END-IF
         IF WS-CONSUMED = 0
             CALL "WOLF-FEED-LOVE" USING L-ROW L-ENTITY WS-CONSUMED
         END-IF
         MOVE 0 TO WS-OWNER
         IF EN-OWNER-UUID(L-ENTITY) = PL-UUID(L-ROW)
             MOVE 1 TO WS-OWNER
         END-IF
         CALL "M188-SIT-TOGGLE" USING EN-SIT(L-ENTITY) WS-CONSUMED WS-OWNER WS-NEW
         IF WS-NEW NOT = EN-SIT(L-ENTITY)
             MOVE WS-NEW TO EN-SIT(L-ENTITY)
             CALL "MOB-DATA-SEND" USING L-ENTITY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-WOLF-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SHEAR-USE.
*> USING player row, entity row (a sheep): shears on a sheep that is not sheared and not a baby (19 section 2.4): 1 + nextInt(3) single wool items of its colour drop, the sheared
*> flag is set and goes to the viewers, the shears lose 1 durability.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 29.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-EV-SHEAR            PIC X(32) VALUE "shear".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     MOVE EN-VARIANT(L-ENTITY) TO WS-BABY
     CALL "M19-SHEEP-SHEAR" USING EN-WOOL(L-ENTITY) WS-BABY WS-DRAW WS-COUNT
     IF WS-COUNT > 0
         COMPUTE WS-COLOR = FUNCTION MOD(EN-WOOL(L-ENTITY), 16)
         CALL "M188-COLOR-KEY" USING WS-COLOR WS-KEY
         CALL "MOB-DROP-ITEMS" USING L-ENTITY WS-KEY WS-COUNT
         CALL "MOB-DATA-SEND" USING L-ENTITY
         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
*>       Sheep.mobInteract: shear at the sheep's position, the player as the source (30-8 14.3.9); the shearing consumed the action, so Mob.interact posts entity_interact (14.3.7)
         CALL "GAME-EVENT-BY" USING WS-EV-SHEAR L-ENTITY PL-ENTITY-ROW(L-ROW)
         CALL "GAME-EVENT-INTERACT" USING L-ENTITY L-ROW
     END-IF
     GOBACK.
 END PROGRAM MOB-SHEAR-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MILK-USE.
*> USING player row, entity row (a cow or mooshroom), held key: an empty bucket on an adult gives a milk bucket (19 section 2.2, M19-COW-MILK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ADULT               BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD.
     MOVE 0 TO WS-ADULT
     IF EN-VARIANT(L-ENTITY) = 0 AND EN-MOBAGE(L-ENTITY) >= 0
         MOVE 1 TO WS-ADULT
     END-IF
     CALL "M19-COW-MILK" USING L-HELD WS-ADULT WS-KEY
     IF WS-KEY NOT = SPACES
         CALL "MOB-ITEM-ID" USING WS-KEY WS-ITEM
         CALL "MOB-SWAP" USING L-ROW WS-ITEM
*>       the milking consumed the action: Mob.interact posts entity_interact at the cow, the player as the source (30-8 14.3.7)
         CALL "GAME-EVENT-INTERACT" USING L-ENTITY L-ROW
     END-IF
     GOBACK.
 END PROGRAM MOB-MILK-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOOSHROOM-USE.
*> USING player row, entity row (a mooshroom), held key: an adult sheared (19 section 2.3): five mushrooms of its type drop and it becomes a cow of the same position, age and
*> health; a bowl on an adult gives mushroom stew (no stored stew effects are modelled).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-COUNT               BINARY-LONG.
 01 WS-STORED              BINARY-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-FULL                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-EV-SHEAR            PIC X(32) VALUE "shear".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD.
     IF EN-VARIANT(L-ENTITY) = 0 AND EN-MOBAGE(L-ENTITY) >= 0
         IF L-HELD = "shears"
             CALL "M19-MOOSHROOM-SHEAR" USING EN-WOOL(L-ENTITY) WS-KEY WS-COUNT
             CALL "MOB-DROP-ITEMS" USING L-ENTITY WS-KEY WS-COUNT
             MOVE SPACES TO WS-FULL
             MOVE "minecraft:cow" TO WS-FULL
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-TYPE WS-ENTITY-ROW WS-STATUS
             MOVE EN-DIM(L-ENTITY) TO WS-DIM
             MOVE EN-X(L-ENTITY) TO WS-X
             MOVE EN-Y(L-ENTITY) TO WS-Y
             MOVE EN-Z(L-ENTITY) TO WS-Z
             MOVE EN-YAW(L-ENTITY) TO WS-YAW
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-COW
             MOVE EN-HEALTH(L-ENTITY) TO EN-HEALTH(WS-COW)
             MOVE EN-MOBAGE(L-ENTITY) TO EN-MOBAGE(WS-COW)
*>           MushroomCow.mobInteract: shear at the mooshroom's position with the player as the source (30-8 14.3.9), then the consumed action's entity_interact (14.3.7); the mooshroom is replaced by the cow
             CALL "GAME-EVENT-BY" USING WS-EV-SHEAR L-ENTITY PL-ENTITY-ROW(L-ROW)
             CALL "GAME-EVENT-INTERACT" USING L-ENTITY L-ROW
             CALL "ENTITY-REMOVE" USING L-ENTITY
             CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
         ELSE
             CALL "M19-MOOSHROOM-BOWL" USING WS-STORED WS-KEY
             CALL "MOB-ITEM-ID" USING WS-KEY WS-ITEM
             CALL "MOB-SWAP" USING L-ROW WS-ITEM
             CALL "GAME-EVENT-INTERACT" USING L-ENTITY L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-MOOSHROOM-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-INTERACT.
*> USING connection id, PLAY-SERVERBOUND (a decoded Interact 0x1A): the main hand of an alive player on a standard passive mob of its dimension that is alive and whose box is
*> within the attack reach: shears on a sheep (MOB-SHEAR-USE), an empty bucket on a cow or mooshroom (MOB-MILK-USE), shears or a bowl on a mooshroom (MOB-MOOSHROOM-USE),
*> otherwise the held item as animal food (MOB-FEED-USE). A wolf: MOB-WOLF-USE; iron ingots on an iron golem: MOB-GOLEM-USE; flint and steel or a fire charge on a creeper:
*> STDMOB-IGNITE (a creeper is the only monster that handles an interaction). A name_tag with a custom_name names any of these mobs (MOB-NAME-TAG-USE, ranged-name.cob); a water_bucket on a fish, axolotl or tadpole takes it into a mob bucket (MOB-BUCKET-PICKUP, ranged-bucket.cob). A golden apple on a zombie villager with Weakness: ZV-USE (T8102). Anything else, and the off hand, is not handled yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY RULES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-KEY48               PIC X(48).
 01 WS-HELD                PIC X(24).
 01 WS-USED                BINARY-LONG.
 01 WS-SNEAK               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE 0 TO WS-ENTITY
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-ENTITY > 0
         IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PSB-TARGET
             MOVE WS-E TO WS-ENTITY
         END-IF
     END-PERFORM
     IF WS-ENTITY = 0 OR PL-STATE(WS-ROW) NOT = PS-ALIVE OR PSB-HAND NOT = 0
         GOBACK
     END-IF
*>   A leash knot (21 section 8.15): within 6 blocks of the player's eyes.
     CALL "MOB-KNOT-TYPE" USING WS-TYPE
     IF EN-TYPE(WS-ENTITY) = WS-TYPE AND EN-DIM(WS-ENTITY) = PL-DIM(WS-ROW)
         COMPUTE WS-DX = EN-X(WS-ENTITY) - PL-X(WS-ROW)
         COMPUTE WS-DY = EN-Y(WS-ENTITY) - (PL-Y(WS-ROW) + RULE-ATTACK-EYE-MILLI / 1000)
         COMPUTE WS-DZ = EN-Z(WS-ENTITY) - PL-Z(WS-ROW)
         IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ <= 36
             MOVE PL-SNEAKING(WS-ROW) TO WS-SNEAK
             CALL "MOB-KNOT-INTERACT" USING WS-ROW WS-ENTITY WS-SNEAK WS-USED
         END-IF
         GOBACK
     END-IF
     IF EN-PLAYER(WS-ENTITY) > 0 OR EN-DIM(WS-ENTITY) NOT = PL-DIM(WS-ROW) OR EN-HEALTH(WS-ENTITY) = 0
         GOBACK
     END-IF
     CALL "BOAT-USE" USING WS-ROW WS-ENTITY WS-USED
     IF WS-USED = 1
         GOBACK
     END-IF
     CALL "DECOR-INTERACT" USING WS-ROW WS-ENTITY PSB-Y WS-USED
     IF WS-USED = 1
         GOBACK
     END-IF
     CALL "HG-INTERACT" USING WS-ROW WS-ENTITY WS-USED
     IF WS-USED = 1
         GOBACK
     END-IF
     CALL "CUSHION-USE" USING WS-ROW WS-ENTITY WS-USED
     IF WS-USED = 1
         GOBACK
     END-IF
     CALL "CG-USE" USING WS-ROW WS-ENTITY WS-USED
     IF WS-USED = 1
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ENTITY) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) WS-KEY48
     END-IF
*>   A hostile mob handles no interaction except the name tag (17 section 3.7), which every living entity takes.
     IF SM-KIND(WS-M) = 1 AND SM-FUSE(WS-M) = 0 AND SM-KEY(WS-M) NOT = "zombie_villager" AND SM-KEY(WS-M) NOT = "piglin"
             AND WS-KEY48 NOT = "name_tag"
             AND SM-KEY(WS-M) NOT = "sulfur_cube"
         GOBACK
     END-IF
     COMPUTE WS-TYPE = EN-TYPE(WS-ENTITY) + 1
     COMPUTE WS-HALF = ET-WIDTH-MILLI(WS-TYPE) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(WS-TYPE) / 1000
     MOVE PL-X(WS-ROW) TO WS-EX
     COMPUTE WS-EY = PL-Y(WS-ROW) + RULE-ATTACK-EYE-MILLI / 1000
     MOVE PL-Z(WS-ROW) TO WS-EZ
     MOVE EN-X(WS-ENTITY) TO WS-TX
     MOVE EN-Y(WS-ENTITY) TO WS-TY
     MOVE EN-Z(WS-ENTITY) TO WS-TZ
     COMPUTE WS-DX = WS-EX - FUNCTION MAX(WS-TX - WS-HALF, FUNCTION MIN(WS-EX, WS-TX + WS-HALF))
     COMPUTE WS-DY = WS-EY - FUNCTION MAX(WS-TY, FUNCTION MIN(WS-EY, WS-TY + WS-HEIGHT))
     COMPUTE WS-DZ = WS-EZ - FUNCTION MAX(WS-TZ - WS-HALF, FUNCTION MIN(WS-EZ, WS-TZ + WS-HALF))
     COMPUTE WS-REACH = RULE-ATTACK-REACH-MILLI / 1000
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ > WS-REACH * WS-REACH
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) WS-KEY48
     END-IF
     MOVE WS-KEY48 TO WS-HELD
     MOVE SM-KEY(WS-M) TO WS-KEY
*>   The item's own interaction comes before the entity's (Player.interactOn): the name tag (17 section 3.7).
     IF WS-HELD = "name_tag"
         CALL "MOB-NAME-TAG-USE" USING WS-ROW WS-ENTITY WS-USED
         IF WS-USED = 1
             GOBACK
         END-IF
     END-IF
     IF WS-KEY = "villager" OR "wandering_trader"
         CALL "MERCHANT-INTERACT" USING WS-ROW WS-ENTITY WS-USED
         IF WS-USED = 1
             CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
             GOBACK
         END-IF
     END-IF
*>   Mob.interact posts entity_interact (the mob's position, the player as the source) after the common interactions (the leash) or mobInteract consumed the action (30-8 14.3.7)
     CALL "MOB-LEASH-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
     IF WS-USED = 1
         CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
         GOBACK
     END-IF
     CALL "NAUTILUS-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
     IF WS-USED = 1
         CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
         GOBACK
     END-IF
     CALL "MOB-EQUINE-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
     IF WS-USED = 1
         CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
         GOBACK
     END-IF
     CALL "MOB-RIDE-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
     IF WS-USED = 1
         CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN WS-HELD = "water_bucket" AND (WS-KEY = "cod" OR "salmon" OR "pufferfish" OR "tropical_fish" OR "axolotl" OR "tadpole")
             CALL "MOB-BUCKET-PICKUP" USING WS-ROW WS-ENTITY WS-USED
         WHEN WS-KEY = "sheep" AND WS-HELD = "shears"
             CALL "MOB-SHEAR-USE" USING WS-ROW WS-ENTITY
         WHEN (WS-KEY = "cow" OR "mooshroom" OR "goat") AND WS-HELD = "bucket"
             CALL "MOB-MILK-USE" USING WS-ROW WS-ENTITY WS-HELD
         WHEN WS-KEY = "mooshroom" AND (WS-HELD = "shears" OR "bowl")
             CALL "MOB-MOOSHROOM-USE" USING WS-ROW WS-ENTITY WS-HELD
         WHEN WS-KEY = "wolf"
             CALL "MOB-WOLF-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "parrot"
             CALL "MOB-PARROT-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "cat" OR "ocelot"
             CALL "MOB-CAT-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "zombie_villager"
             CALL "ZV-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
         WHEN WS-KEY = "piglin"
             CALL "PIGLIN-USE" USING WS-ROW WS-ENTITY WS-HELD WS-USED
         WHEN WS-KEY = "iron_golem" AND WS-HELD = "iron_ingot"
             CALL "MOB-GOLEM-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "tadpole"
             CALL "MOB-TADPOLE-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "allay"
             CALL "MOB-ALLAY-USE" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "armadillo" AND WS-HELD = "brush"
             CALL "MOB-ARMADILLO-BRUSH" USING WS-ROW WS-ENTITY
         WHEN WS-KEY = "creeper"
             CALL "STDMOB-IGNITE" USING WS-ROW WS-ENTITY WS-HELD
         WHEN WS-KEY = "sulfur_cube"
             CALL "SULFUR-USE" USING WS-ROW WS-ENTITY WS-HELD
         WHEN OTHER
             CALL "MOB-FEED-USE" USING WS-ROW WS-ENTITY
     END-EVALUATE
*>   A zombie villager's golden apple and a piglin's barter are the species programs that report the action as consumed
     IF WS-USED = 1
         CALL "GAME-EVENT-INTERACT" USING WS-ENTITY WS-ROW
     END-IF
     GOBACK.
 END PROGRAM MOB-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-TAME-FLAGS.
*> USING tame, sit, flags out: metadata slot 18 of a TamableAnimal (8.2): bit 4 is tame, bit 1 the sitting pose.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TAME                 BINARY-LONG.
 01 L-SIT                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TAME L-SIT L-FLAGS.
     COMPUTE L-FLAGS = L-TAME * 4 + L-SIT
     GOBACK.
 END PROGRAM M188-TAME-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-TAME-TRY.
*> USING draw (nextInt(3), 0 to 2), ok out: the taming roll of a wolf (19 section 6.1): nextInt(3) = 0 tames.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-OK.
     MOVE 0 TO L-OK
     IF L-DRAW = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM M188-TAME-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-OWNER-FAR.
*> USING squared distance to the owner, far out: shouldTryTeleportToOwner, 1 at 144 (12 blocks) or more (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-FAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-FAR.
     MOVE 0 TO L-FAR
     IF L-D2 >= 144
         MOVE 1 TO L-FAR
     END-IF
     GOBACK.
 END PROGRAM M188-OWNER-FAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-FOLLOW.
*> USING squared distance to the owner, moving (1 while it walks to the owner), action out: FollowOwnerGoal(1.0, 10.0, 2.0) with the teleport of 12 blocks (8.2):
*> 2 teleport at 144 or more, 1 walk (start farther than 10 blocks, or keep walking beyond 2 blocks), 3 stop (a walking pet within 2 blocks), 0 nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-MOVING               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-MOVING L-ACTION.
     CALL "M188-OWNER-FAR" USING L-D2 WS-FAR
     EVALUATE TRUE
         WHEN WS-FAR = 1
             MOVE 2 TO L-ACTION
         WHEN L-MOVING = 0 AND L-D2 > 100
             MOVE 1 TO L-ACTION
         WHEN L-MOVING = 1 AND L-D2 > 4
             MOVE 1 TO L-ACTION
         WHEN L-MOVING = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 0 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM M188-FOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M188-SIT-TOGGLE.
*> USING sit, consumed, owner, new sit out: when the base interaction consumed nothing and the player is the owner, the sit order toggles (19 section 6.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SIT                  BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIT L-CONSUMED L-OWNER L-NEW.
     MOVE L-SIT TO L-NEW
     IF L-CONSUMED = 0 AND L-OWNER = 1
         COMPUTE L-NEW = 1 - L-SIT
     END-IF
     GOBACK.
 END PROGRAM M188-SIT-TOGGLE.
