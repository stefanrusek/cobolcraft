*> Test (US15; docs/protocol/18-mob-framework.md section 8.1; docs/protocol/19 section 3.4 and 44 part 1 section 4): the pure rules of love mode, feeding, ageing
*> and breeding in core/src/mob-18-8.cob (M188-*). The live wiring is tested by acc_us15_breeding.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-8-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-KEY                PIC X(24).
 01 WS-SPECIES            PIC X(24).
 01 WS-OTHER              PIC X(24).
 01 WS-ITEM               PIC X(24).
 01 WS-FOUND              BINARY-LONG.
 01 WS-SECONDS            BINARY-LONG.
 01 WS-LOVE               BINARY-LONG.
 01 WS-TAME               BINARY-LONG.
 01 WS-AGE                BINARY-LONG.
 01 WS-INLOVE             BINARY-LONG.
 01 WS-LOCKED             BINARY-LONG.
 01 WS-FORCED             BINARY-LONG.
 01 WS-GROWN              BINARY-LONG.
 01 WS-ACTION             BINARY-LONG.
 01 WS-CAN                BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-FOODS.
    05 FILLER PIC X(51) VALUE "pig                     carrot                  1".
    05 FILLER PIC X(51) VALUE "pig                     potato                  1".
    05 FILLER PIC X(51) VALUE "pig                     beetroot                1".
    05 FILLER PIC X(51) VALUE "pig                     wheat                   0".
    05 FILLER PIC X(51) VALUE "cow                     wheat                   1".
    05 FILLER PIC X(51) VALUE "cow                     carrot                  0".
    05 FILLER PIC X(51) VALUE "mooshroom               wheat                   1".
    05 FILLER PIC X(51) VALUE "sheep                   wheat                   1".
    05 FILLER PIC X(51) VALUE "chicken                 wheat_seeds             1".
    05 FILLER PIC X(51) VALUE "chicken                 melon_seeds             1".
    05 FILLER PIC X(51) VALUE "chicken                 pumpkin_seeds           1".
    05 FILLER PIC X(51) VALUE "chicken                 beetroot_seeds          1".
    05 FILLER PIC X(51) VALUE "chicken                 torchflower_seeds       1".
    05 FILLER PIC X(51) VALUE "chicken                 pitcher_pod             1".
    05 FILLER PIC X(51) VALUE "chicken                 wheat                   0".
    05 FILLER PIC X(51) VALUE "rabbit                  carrot                  1".
    05 FILLER PIC X(51) VALUE "rabbit                  golden_carrot           1".
    05 FILLER PIC X(51) VALUE "rabbit                  dandelion               1".
    05 FILLER PIC X(51) VALUE "goat                    wheat                   1".
    05 FILLER PIC X(51) VALUE "fox                     sweet_berries           1".
    05 FILLER PIC X(51) VALUE "fox                     glow_berries            1".
    05 FILLER PIC X(51) VALUE "panda                   bamboo                  1".
    05 FILLER PIC X(51) VALUE "camel                   cactus                  1".
    05 FILLER PIC X(51) VALUE "llama                   wheat                   1".
    05 FILLER PIC X(51) VALUE "llama                   hay_block               1".
    05 FILLER PIC X(51) VALUE "horse                   golden_carrot           1".
    05 FILLER PIC X(51) VALUE "donkey                  hay_block               1".
    05 FILLER PIC X(51) VALUE "mule                    apple                   1".
    05 FILLER PIC X(51) VALUE "zombie                  wheat                   0".
 01 WS-FOOD-TABLE REDEFINES WS-FOODS.
    05 WS-FOOD               OCCURS 29 TIMES.
       10 WS-F-SPECIES       PIC X(24).
       10 WS-F-ITEM          PIC X(24).
       10 WS-F-FOUND         PIC 9.
       10 FILLER             PIC XX.
 PROCEDURE DIVISION.
*> 8.1 / 19 section 2: the foods of each species (the item tags pig_food, cow_food, sheep_food, chicken_food, rabbit_food, goat_food, fox_food, panda_food,
*> camel_food, llama_food and horse_food)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         MOVE WS-F-SPECIES(WS-I) TO WS-SPECIES
         MOVE WS-F-ITEM(WS-I) TO WS-ITEM
         CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
         MOVE "acceptance US15 18§8.1 Love mode and breeding: the foods each species accepts (item tags of 19 section 2)" TO WS-CASE
         MOVE WS-F-FOUND(WS-I) TO WS-E
         MOVE WS-FOUND TO WS-O
         PERFORM CHECK-N
     END-PERFORM
*>   Ordinary animals: love needs no taming, the baby age-up is the formula (seconds 0 here); horses, donkeys, llamas and camels need a tamed adult.
     MOVE "pig" TO WS-SPECIES
     MOVE "carrot" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a pig's food starts love, with the 10 percent formula, with no taming" TO WS-CASE
     COMPUTE WS-O = WS-LOVE * 100 + WS-SECONDS * 10 + WS-TAME
     COMPUTE WS-E = 100
     PERFORM CHECK-N
     MOVE "horse" TO WS-SPECIES
     MOVE "golden_carrot" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 18§8.1 Love mode and breeding: golden carrot for a horse: 60 s, love, tamed only (19 section 3.4)" TO WS-CASE
     COMPUTE WS-E = 60 * 100 + 10 + 1
     COMPUTE WS-O = WS-SECONDS * 100 + WS-LOVE * 10 + WS-TAME
     PERFORM CHECK-N
     MOVE "wheat" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 18§8.1 Love mode and breeding: wheat for a horse ages a baby 20 s but does not start love" TO WS-CASE
     COMPUTE WS-E = 20 * 100 + 0 * 10 + 1
     COMPUTE WS-O = WS-SECONDS * 100 + WS-LOVE * 10 + WS-TAME
     PERFORM CHECK-N
     MOVE "camel" TO WS-SPECIES
     MOVE "cactus" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 18§8.1 Love mode and breeding: cactus for a camel ages a baby 10 s and starts love of a tamed adult (19 section 3.4)" TO WS-CASE
     COMPUTE WS-E = 10 * 100 + 1 * 10 + 1
     COMPUTE WS-O = WS-SECONDS * 100 + WS-LOVE * 10 + WS-TAME
     PERFORM CHECK-N
     MOVE "llama" TO WS-SPECIES
     MOVE "hay_block" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 18§8.1 Love mode and breeding: hay block for a llama ages a baby 90 s and starts love of a tamed adult" TO WS-CASE
     COMPUTE WS-E = 90 * 100 + 1 * 10 + 1
     COMPUTE WS-O = WS-SECONDS * 100 + WS-LOVE * 10 + WS-TAME
     PERFORM CHECK-N

*> Which species breed at all
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE "pig" TO WS-SPECIES MOVE 1 TO WS-E
             WHEN 2 MOVE "mooshroom" TO WS-SPECIES MOVE 1 TO WS-E
             WHEN 3 MOVE "horse" TO WS-SPECIES MOVE 1 TO WS-E
             WHEN 4 MOVE "mule" TO WS-SPECIES MOVE 0 TO WS-E
             WHEN 5 MOVE "zombie" TO WS-SPECIES MOVE 0 TO WS-E
             WHEN 6 MOVE "armadillo" TO WS-SPECIES MOVE 0 TO WS-E
             WHEN 7 MOVE "panda" TO WS-SPECIES MOVE 1 TO WS-E
             WHEN 8 MOVE "camel" TO WS-SPECIES MOVE 1 TO WS-E
         END-EVALUATE
         CALL "M188-BREEDS" USING WS-SPECIES WS-OK
         MOVE "acceptance US15 18§8.1 Love mode and breeding: the species whose animals can fall in love (a mule cannot: canMate is false)" TO WS-CASE
         MOVE WS-OK TO WS-O
         PERFORM CHECK-N
     END-PERFORM

*> Feeding (Animal.mobInteract): love branch first (age 0, not in love, may fall in love), else the baby branch
     MOVE 0 TO WS-AGE WS-INLOVE
     MOVE 0 TO WS-SECONDS
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a food item that the species does not accept does nothing" TO WS-CASE
     MOVE 0 TO WS-FOUND
     MOVE 1 TO WS-CAN
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-FOUND
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: food for an adult of age 0 not in love: love mode (action 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-INLOVE
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: food for an adult already in love is not eaten" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-INLOVE
     MOVE 6000 TO WS-AGE
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: food for an adult in breeding cooldown (age 6000) is not eaten" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-AGE
     MOVE 0 TO WS-CAN
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: an animal that may not fall in love (an untamed horse) does not eat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-CAN
     MOVE -24000 TO WS-AGE
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: food for a new baby ages it 10 percent of the 1200 s left: 120 s" TO WS-CASE
     COMPUTE WS-E = 2 * 1000 + 120
     COMPUTE WS-O = WS-ACTION * 1000 + WS-A
     PERFORM CHECK-N
     MOVE -100 TO WS-AGE
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: 100 ticks left is 5 s, 10 percent of that truncates to 0 s, the food is still used" TO WS-CASE
     COMPUTE WS-E = 2 * 1000 + 0
     COMPUTE WS-O = WS-ACTION * 1000 + WS-A
     PERFORM CHECK-N
     MOVE -2000 TO WS-AGE
     MOVE 20 TO WS-SECONDS
     CALL "M188-FEED" USING WS-AGE WS-INLOVE WS-FOUND WS-SECONDS WS-CAN WS-ACTION WS-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a species with a fixed age-up (horse wheat) gives its own seconds" TO WS-CASE
     COMPUTE WS-E = 2 * 1000 + 20
     COMPUTE WS-O = WS-ACTION * 1000 + WS-A
     PERFORM CHECK-N

*> Forced ageing: ageUp adds seconds x 20 and clamps at 0; the forced timer is 40 ticks
     MOVE -24000 TO WS-AGE
     MOVE 0 TO WS-FORCED
     MOVE 120 TO WS-SECONDS
     CALL "M188-AGE-UP" USING WS-AGE WS-SECONDS WS-FORCED
     MOVE "acceptance US15 18§8.1 Love mode and breeding: ageUp(120 s) of a new baby leaves -21600 and starts the 40-tick forced-age effect" TO WS-CASE
     COMPUTE WS-E = -21600 * 100 + 40
     COMPUTE WS-O = WS-AGE * 100 + WS-FORCED
     PERFORM CHECK-N
     MOVE -50 TO WS-AGE
     MOVE 10 TO WS-SECONDS
     CALL "M188-AGE-UP" USING WS-AGE WS-SECONDS WS-FORCED
     MOVE "acceptance US15 18§8.1 Love mode and breeding: ageUp never passes 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-AGE TO WS-O
     PERFORM CHECK-N
     MOVE 6000 TO WS-AGE
     MOVE 0 TO WS-FORCED
     CALL "M188-AGE-UP" USING WS-AGE WS-SECONDS WS-FORCED
     MOVE "acceptance US15 18§8.1 Love mode and breeding: ageUp does nothing to an adult in cooldown" TO WS-CASE
     COMPUTE WS-E = 6000 * 100
     COMPUTE WS-O = WS-AGE * 100 + WS-FORCED
     PERFORM CHECK-N

*> Each tick (AgeableMob.aiStep then Animal.aiStep)
     MOVE -24000 TO WS-AGE
     MOVE 0 TO WS-INLOVE WS-LOCKED WS-FORCED
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a baby's age counts up by 1 a tick" TO WS-CASE
     MOVE -23999 TO WS-E
     MOVE WS-AGE TO WS-O
     PERFORM CHECK-N
     MOVE -1 TO WS-AGE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: at age 0 the baby has grown up (the age boundary is reached)" TO WS-CASE
     COMPUTE WS-E = 0 * 10 + 1
     COMPUTE WS-O = WS-AGE * 10 + WS-GROWN
     PERFORM CHECK-N
     MOVE 6000 TO WS-AGE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the breeding cooldown counts down by 1 a tick (6000 ticks = 5 minutes)" TO WS-CASE
     COMPUTE WS-E = 5999 * 10
     COMPUTE WS-O = WS-AGE * 10 + WS-GROWN
     PERFORM CHECK-N
     MOVE 1 TO WS-AGE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the cooldown ending is not a growing up" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-AGE * 10 + WS-GROWN
     PERFORM CHECK-N
     MOVE 1 TO WS-LOCKED
     MOVE 600 TO WS-AGE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: an age-locked mob's cooldown does not count" TO WS-CASE
     MOVE 600 TO WS-E
     MOVE WS-AGE TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-LOCKED
     MOVE 0 TO WS-AGE
     MOVE 600 TO WS-INLOVE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: love counts down by 1 a tick" TO WS-CASE
     MOVE 599 TO WS-E
     MOVE WS-INLOVE TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-INLOVE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: love ends after its 600th tick" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INLOVE TO WS-O
     PERFORM CHECK-N
     MOVE -5 TO WS-AGE
     MOVE 100 TO WS-INLOVE
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a mob whose age is not 0 is not in love" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INLOVE TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-AGE
     MOVE 40 TO WS-FORCED
     CALL "M188-TICK" USING WS-AGE WS-INLOVE WS-LOCKED WS-FORCED WS-GROWN
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the forced-age timer counts down a tick" TO WS-CASE
     MOVE 39 TO WS-E
     MOVE WS-FORCED TO WS-O
     PERFORM CHECK-N

*> canMate
     MOVE "cow" TO WS-SPECIES
     MOVE "cow" TO WS-OTHER
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: two cows in love can mate" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-B
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: both partners must be in love" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-B
     MOVE "mooshroom" TO WS-OTHER
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a cow and a mooshroom are of different classes and cannot mate" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "horse" TO WS-SPECIES
     MOVE "donkey" TO WS-OTHER
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a horse and a donkey in love can mate (19 section 3.5)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "donkey" TO WS-SPECIES
     MOVE "horse" TO WS-OTHER
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a donkey and a horse in love can mate" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "mule" TO WS-SPECIES
     MOVE "mule" TO WS-OTHER
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: two mules never mate" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "pig" TO WS-SPECIES
     MOVE "cow" TO WS-OTHER
     CALL "M188-CAN-MATE" USING WS-SPECIES WS-OTHER WS-A WS-B WS-OK
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a pig and a cow cannot mate" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N

*> Offspring species (getBreedOffspring)
     MOVE "horse" TO WS-SPECIES
     MOVE "donkey" TO WS-OTHER
     CALL "M188-OFFSPRING" USING WS-SPECIES WS-OTHER WS-KEY
     MOVE "acceptance US15 18§8.1 Love mode and breeding: horse x donkey gives a mule" TO WS-CASE
     PERFORM CHECK-KEY-MULE
     MOVE "donkey" TO WS-SPECIES
     MOVE "horse" TO WS-OTHER
     CALL "M188-OFFSPRING" USING WS-SPECIES WS-OTHER WS-KEY
     MOVE "acceptance US15 18§8.1 Love mode and breeding: donkey x horse gives a mule" TO WS-CASE
     PERFORM CHECK-KEY-MULE
     MOVE "donkey" TO WS-OTHER
     CALL "M188-OFFSPRING" USING WS-SPECIES WS-OTHER WS-KEY
     MOVE "acceptance US15 18§8.1 Love mode and breeding: donkey x donkey gives a donkey" TO WS-CASE
     MOVE 0 TO WS-E
     IF WS-KEY = "donkey"
         MOVE 0 TO WS-O
     ELSE
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "sheep" TO WS-SPECIES
     MOVE "sheep" TO WS-OTHER
     CALL "M188-OFFSPRING" USING WS-SPECIES WS-OTHER WS-KEY
     MOVE "acceptance US15 18§8.1 Love mode and breeding: two sheep give a sheep" TO WS-CASE
     MOVE 0 TO WS-E
     IF WS-KEY = "sheep"
         MOVE 0 TO WS-O
     ELSE
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 CHECK-KEY-MULE.
     MOVE 0 TO WS-E
     IF WS-KEY = "mule"
         MOVE 0 TO WS-O
     ELSE
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-8-1.
