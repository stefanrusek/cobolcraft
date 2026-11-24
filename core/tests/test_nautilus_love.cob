*> Implementation test (wrap I2 round 6, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 10.1, 10.2 and 10.5 with 18 section 4.6 and 8.1): love mode and babies of the
*> nautilus. The food table (nautilus_food) and the breeders list; feeding by interaction (a tame adult at full health falls in love for 600 ticks, an untamed one does not, a bucket food leaves a
*> water bucket, a baby ages up by 10 percent, a hurt tame one is healed first); the baby flag (metadata 16) of a nautilus, never of a zombie nautilus; the age and love counters of NAUTILUS-TICK;
*> AnimalMakeLove(NAUTILUS, 0.4, 2): the closest partner in love becomes the BREED_TARGET of both, both walk to each other at speed 0.4, the random delay 60 + nextInt(50), the child within 3
*> blocks (owner and tame copied from the first parent), the stop on 110 ticks, a broken pairing or panic, and no ChargeAttack while a BREED_TARGET is present; a zombie nautilus has no love.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAUTILUS-LOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WCSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-TYPE-Z              BINARY-LONG.
 01 WS-TYPE-P              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-Z-ROW               BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-ID-A                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BABY-ROW            BINARY-LONG.
 01 WS-HAS-BABY            BINARY-LONG.
 01 WS-FOOD-SPECIES        PIC X(24).
 01 WS-FOOD-ITEM           PIC X(24).
 01 WS-FOUND               BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-TAME                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-COD                 BINARY-LONG.
 01 WS-COD-BUCKET          BINARY-LONG.
 01 WS-WATER-BUCKET        BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-OWNER-A             PIC X(16) VALUE "aaaaaaaa00000001".
 01 WS-OWNER-B             PIC X(16) VALUE "bbbbbbbb00000002".
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "minecraft:nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE-N WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE-Z WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE-P WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COD WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cod_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COD-BUCKET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:water_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-WATER-BUCKET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS

*>   The food table and the breeders list (10.1: nautilus_food; the zombie nautilus has no love).
     MOVE "nautilus" TO WS-FOOD-SPECIES
     MOVE "cod" TO WS-FOOD-ITEM
     CALL "M188-FOOD" USING WS-FOOD-SPECIES WS-FOOD-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "implementation 44-7 10.2 cod is nautilus food that can start love" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-FOUND * WS-LOVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.2 love needs a tamed adult (the tame flag of the food row)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-TAME TO WS-OBSERVE
     PERFORM CHECK
     MOVE "cod_bucket" TO WS-FOOD-ITEM
     CALL "M188-FOOD" USING WS-FOOD-SPECIES WS-FOOD-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "implementation 44-7 9.3 a cod bucket is nautilus_bucket_food" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "cobblestone" TO WS-FOOD-ITEM
     CALL "M188-FOOD" USING WS-FOOD-SPECIES WS-FOOD-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "implementation 44-7 9.3 cobblestone is no nautilus food" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-FOUND + WS-LOVE
     PERFORM CHECK
     MOVE "zombie_nautilus" TO WS-FOOD-SPECIES
     MOVE "cod" TO WS-FOOD-ITEM
     CALL "M188-FOOD" USING WS-FOOD-SPECIES WS-FOOD-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "implementation 44-7 10.8 a zombie nautilus has no food" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK
     CALL "M188-BREEDS" USING WS-FOOD-SPECIES WS-OK
     MOVE "implementation 44-7 10.1 a zombie nautilus cannot breed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE "nautilus" TO WS-FOOD-SPECIES
     CALL "M188-BREEDS" USING WS-FOOD-SPECIES WS-OK
     MOVE "implementation 44-7 10.1 a nautilus can fall in love" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK

*>   Feeding by interaction: the mob next to the player (the reach).
     COMPUTE WS-X = PL-X(WS-PLAYER)
     COMPUTE WS-Y = PL-Y(WS-PLAYER)
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE WS-TYPE-N TO WS-TYPE
     PERFORM SPAWN-ROW
     MOVE WS-ROW TO WS-A
     MOVE EN-ID(WS-A) TO WS-ID-A
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 15 TO EN-HEALTH(WS-A)
     MOVE 0 TO EN-TAMED(WS-A)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 an untamed adult is not made fall in love by a cod" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.2 and the cod is not used up" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO EN-TAMED(WS-A)
     MOVE WS-OWNER-A TO EN-OWNER-UUID(WS-A)
     MOVE 10 TO EN-HEALTH(WS-A)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 step 2b: a hurt tame nautilus is healed first and does not fall in love" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 15 TO EN-HEALTH(WS-A)
     MOVE 4 TO WS-EXPECT
     MOVE "implementation 44-7 10.2 step 2b used one cod" TO WS-CASE
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 step 4 with 8.1: a tame adult at full health falls in love for 600 ticks" TO WS-CASE
     MOVE 600 TO WS-EXPECT
     MOVE EN-LOVE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.2 the love cause is the feeding player" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-LOVE-CAUSE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.2 one cod was used for the love" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
*>   A bucket food leaves a water bucket (usePlayerItem, 10.2).
     MOVE 0 TO EN-LOVE(WS-A)
     MOVE WS-COD-BUCKET TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a cod bucket starts love as well" TO WS-CASE
     MOVE 600 TO WS-EXPECT
     MOVE EN-LOVE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.2 the bucket food leaves a water bucket in the hand" TO WS-CASE
     MOVE WS-WATER-BUCKET TO WS-EXPECT
     MOVE PL-SLOT-ITEM(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
*>   A baby (untamed or not): the age rises by 10 percent of the remaining time, 2400 ticks of 24000.
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO EN-LOVE(WS-A)
     MOVE 0 TO EN-TAMED(WS-A)
     MOVE -24000 TO EN-MOBAGE(WS-A)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 step 4 with 8.1: a cod ages a baby nautilus up by 10 percent of the remaining time" TO WS-CASE
     MOVE -21600 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-A)

*>   The baby flag (metadata 16) of a nautilus, derived from its age; a zombie nautilus is never a baby.
     MOVE -100 TO EN-MOBAGE(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 10.1 a baby nautilus sends the baby flag" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-BABY * 10 + WS-NEEDED
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 10.1 an adult nautilus sends no baby flag" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-BABY TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-TYPE-Z TO WS-TYPE
     PERFORM SPAWN-ROW
     MOVE WS-ROW TO WS-Z-ROW
     MOVE -100 TO EN-MOBAGE(WS-Z-ROW)
     CALL "MOB-DATA-VALUES" USING WS-Z-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 10.1 a zombie nautilus is never a baby" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-BABY TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-Z-ROW)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)

*>   The age and love counters of NAUTILUS-TICK (AgeableMob.aiStep and Animal.aiStep).
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 4.5
     MOVE WS-TYPE-N TO WS-TYPE
     CALL "STDMOB-INDEX" USING WS-TYPE-N WS-M
     CALL "STDMOB-INDEX" USING WS-TYPE-Z WS-MZ
     MOVE WS-A TO WS-ROW
     MOVE WS-X TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     MOVE WS-Z TO EN-Z(WS-A)
     MOVE 0 TO EN-TAMED(WS-A) EN-LOVE(WS-A)
     MOVE -2 TO EN-MOBAGE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 8.1 a baby's age counts up by one a tick" TO WS-CASE
     MOVE -1 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 8.1 at age 0 the baby has grown up and sends no baby flag" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-A) + WS-BABY
     PERFORM CHECK
     MOVE 600 TO EN-LOVE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 8.1 love counts down by one a tick" TO WS-CASE
     MOVE 599 TO WS-EXPECT
     MOVE EN-LOVE(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 6000 TO EN-MOBAGE(WS-A)
     MOVE 10 TO EN-LOVE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 8.1 a breeding cooldown counts down and ends love" TO WS-CASE
     MOVE 5999 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-A) + EN-LOVE(WS-A)
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-A)
*>   A zombie nautilus has neither age nor love (10.8).
     MOVE WS-X TO EN-X(WS-Z-ROW)
     MOVE WS-Y TO EN-Y(WS-Z-ROW)
     MOVE WS-Z TO EN-Z(WS-Z-ROW)
     MOVE 10 TO EN-LOVE(WS-Z-ROW)
     CALL "NAUTILUS-TICK" USING WS-Z-ROW WS-MZ WS-ONE
     MOVE "implementation 44-7 10.8 a zombie nautilus keeps its love counter and starts no pairing" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE(WS-Z-ROW) + EN-LOVE-PARTNER(WS-Z-ROW)
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-Z-ROW

*>   AnimalMakeLove: two tame adults in love, 5 blocks apart, the first with the owner A.
     MOVE 0 TO EN-LOVE(WS-A)
     COMPUTE WS-X = WS-X0 + 2.5
     MOVE WS-X TO EN-X(WS-A)
     MOVE 1 TO EN-TAMED(WS-A)
     MOVE WS-OWNER-A TO EN-OWNER-UUID(WS-A)
     COMPUTE WS-X = WS-X0 + 7.5
     MOVE WS-TYPE-N TO WS-TYPE
     PERFORM SPAWN-ROW
     MOVE WS-ROW TO WS-B
     MOVE 1 TO EN-TAMED(WS-B)
     MOVE WS-OWNER-B TO EN-OWNER-UUID(WS-B)
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     MOVE 0 TO EN-MOBAGE(WS-A) EN-MOBAGE(WS-B)
     MOVE 0 TO EN-FLEE(WS-A) EN-FLEE(WS-B)
     MOVE 0 TO EN-SWIM-SPEED(WS-A) EN-SWIM-SPEED(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 AnimalMakeLove: the closest partner in love is the BREED_TARGET" TO WS-CASE
     MOVE WS-B TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 AnimalMakeLove sets the BREED_TARGET of the partner as well" TO WS-CASE
     MOVE WS-A TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-B) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 the starter leads the pairing, the partner only walks" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-LOVE-LEAD(WS-A) * 10 + WC-NAU-LOVE-LEAD(WS-B)
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 and 18 4.6 the delay is 60 + nextInt(50) ticks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-NAU-LOVE-DELAY(WS-A) >= 60 AND WC-NAU-LOVE-DELAY(WS-A) <= 109
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 the starter walks to its partner at speed 0.4 (the swim speed lerps 0.125)" TO WS-CASE
     MOVE 50 TO WS-EXPECT
     COMPUTE WS-OBSERVE ROUNDED = EN-SWIM-SPEED(WS-A) * 1000
     PERFORM CHECK
     CALL "NAUTILUS-TICK" USING WS-B WS-M WS-ONE
     MOVE "implementation 44-7 10.5 the partner walks to the starter at speed 0.4 too" TO WS-CASE
     MOVE 50 TO WS-EXPECT
     COMPUTE WS-OBSERVE ROUNDED = EN-SWIM-SPEED(WS-B) * 1000
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 the BREED_TARGET of the partner is kept by its own tick" TO WS-CASE
     MOVE WS-A TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-B) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 90 TO WC-NAU-LOVE-DELAY(WS-A)
     PERFORM COUNT-NAUTILUS
     MOVE "implementation 44-7 10.5 five blocks apart nothing is born" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-N TO WS-OBSERVE
     PERFORM CHECK

*>   Within 3 blocks the child is born only once the delay has run out.
     COMPUTE WS-X = WS-X0 + 4.5
     MOVE WS-X TO EN-X(WS-B)
     MOVE 2 TO WC-NAU-LOVE-DELAY(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     PERFORM COUNT-NAUTILUS
     MOVE "implementation 44-7 10.5 within 3 blocks but before the delay ran out nothing is born" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-N TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.5 the delay counts down a tick" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WC-NAU-LOVE-DELAY(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     PERFORM COUNT-NAUTILUS
     MOVE "implementation 44-7 10.5 within 3 blocks and past the delay the child is born" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-N TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 8.1 both parents get the cooldown age 6000" TO WS-CASE
     MOVE 12000 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-A) + EN-MOBAGE(WS-B)
     PERFORM CHECK
     MOVE "implementation 44-7 8.1 both parents leave love mode and the pairing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE(WS-A) + EN-LOVE(WS-B) + EN-LOVE-PARTNER(WS-A) + EN-LOVE-PARTNER(WS-B) + WC-NAU-LOVE-LEAD(WS-A)
     PERFORM CHECK
     PERFORM FIND-BABY
     MOVE "implementation 44-7 8.1 the child is a baby of age -24000" TO WS-CASE
     MOVE -24000 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.1 the child of a tame parent is tame" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-TAMED(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.1 the child's owner is the first parent's owner" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-OWNER-UUID(WS-BABY-ROW) = WS-OWNER-A
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     CALL "MOB-DATA-VALUES" USING WS-BABY-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 10.1 the child sends the baby flag" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-BABY TO WS-OBSERVE
     PERFORM CHECK
*>   An untamed pair has an untamed child.
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     MOVE 0 TO EN-TAMED(WS-A) EN-TAMED(WS-B)
     MOVE SPACES TO EN-OWNER-UUID(WS-A)
     MOVE 0 TO EN-MOBAGE(WS-A) EN-MOBAGE(WS-B)
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE 0 TO WC-NAU-LOVE-DELAY(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     PERFORM FIND-BABY
     MOVE "implementation 44-7 10.1 an untamed pair also has a child" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HAS-BABY TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.1 the child of an untamed parent is untamed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE 9 TO WS-OBSERVE
     IF WS-HAS-BABY = 1
         MOVE EN-TAMED(WS-BABY-ROW) TO WS-OBSERVE
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     PERFORM CHECK

*>   Interruptions: no start while panicking or when not in love; a broken pairing, panic and the 110 ticks end it.
     MOVE 0 TO EN-MOBAGE(WS-A) EN-MOBAGE(WS-B)
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     MOVE 5 TO EN-FLEE(WS-A)
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 a panicking nautilus does not start AnimalMakeLove" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-FLEE(WS-A)
     MOVE 0 TO EN-LOVE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 no partner in love: no pairing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 600 TO EN-LOVE(WS-B)
     MOVE 0 TO EN-LOVE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 a nautilus not in love starts no pairing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 600 TO EN-LOVE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 the pairing starts again" TO WS-CASE
     MOVE WS-B TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-LOVE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 canStillUse: the partner left love mode, the pairing ends on both sides" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE-PARTNER(WS-A) + EN-LOVE-PARTNER(WS-B) + WC-NAU-LOVE-LEAD(WS-A)
     PERFORM CHECK
     MOVE 600 TO EN-LOVE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE 5 TO EN-FLEE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 canStillUse: a panicking partner ends the pairing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE-PARTNER(WS-A) + EN-LOVE-PARTNER(WS-B)
     PERFORM CHECK
     MOVE 0 TO EN-FLEE(WS-B)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE 110 TO EN-LOVE-TIME(WS-A)
     MOVE 90 TO WC-NAU-LOVE-DELAY(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 the behaviour runs for 110 ticks, then it ends on both sides" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE-PARTNER(WS-A) + EN-LOVE-PARTNER(WS-B)
     PERFORM CHECK

*>   FIGHT needs BREED_TARGET absent: no ChargeAttack starts while the pairing stands.
     COMPUTE WS-X = WS-X0 + 7.5
     MOVE WS-X TO EN-X(WS-B)
     MOVE WS-TYPE-P TO WS-TYPE
     COMPUTE WS-X = WS-X0 + 6.5
     PERFORM SPAWN-ROW
     MOVE WS-ROW TO WS-PF
     MOVE 1 TO WC-NAU-INIT(WS-A)
     MOVE 0 TO WC-NAU-ATTACK-CD(WS-A) WC-NAU-CHARGE-CD(WS-A) WC-NAU-CHARGING(WS-A)
     MOVE WS-PF TO EN-FOE(WS-A)
     MOVE EN-ID(WS-PF) TO EN-FOE-ID(WS-A)
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     MOVE WS-B TO EN-LOVE-PARTNER(WS-A)
     MOVE WS-A TO EN-LOVE-PARTNER(WS-B)
     MOVE 1 TO WC-NAU-LOVE-LEAD(WS-A)
     MOVE 0 TO WC-NAU-LOVE-LEAD(WS-B)
     MOVE 1 TO EN-LOVE-TIME(WS-A)
     MOVE 90 TO WC-NAU-LOVE-DELAY(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 FIGHT: no ChargeAttack starts while a BREED_TARGET is present" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-NAU-CHARGING(WS-A) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-LOVE-PARTNER(WS-A) EN-LOVE-PARTNER(WS-B) WC-NAU-LOVE-LEAD(WS-A) EN-LOVE(WS-A) EN-LOVE(WS-B)
     MOVE 0 TO EN-MOBAGE(WS-A)
     CALL "NAUTILUS-TICK" USING WS-A WS-M WS-ONE
     MOVE "implementation 44-7 10.5 FIGHT: without a BREED_TARGET the charge starts" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-NAU-CHARGING(WS-A) > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
*>   The partner side of a pairing ends when the starter no longer points at it.
     MOVE 0 TO EN-LOVE-PARTNER(WS-A)
     MOVE WS-A TO EN-LOVE-PARTNER(WS-B)
     MOVE 0 TO WC-NAU-LOVE-LEAD(WS-B)
     CALL "NAUTILUS-TICK" USING WS-B WS-M WS-ONE
     MOVE "implementation 44-7 10.5 the partner stops walking when the starter's pairing is gone" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-B) TO WS-OBSERVE
     PERFORM CHECK
     STOP RUN.
*> SPAWN-ROW: a mob of WS-TYPE at WS-X, WS-Y, WS-Z in the dimension; the row in WS-ROW
 SPAWN-ROW.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.
*> COUNT-NAUTILUS: the number of nautilus rows (WS-N)
 COUNT-NAUTILUS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE-N
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
*> FIND-BABY: the nautilus row that is neither WS-A nor WS-B (WS-HAS-BABY 1); without one WS-BABY-ROW is WS-A so that the checks read a real row and fail by their values
 FIND-BABY.
     MOVE 0 TO WS-HAS-BABY
     MOVE WS-A TO WS-BABY-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE-N AND WS-I NOT = WS-A AND WS-I NOT = WS-B
             MOVE WS-I TO WS-BABY-ROW
             MOVE 1 TO WS-HAS-BABY
         END-IF
     END-PERFORM.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NAUTILUS-LOVE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
