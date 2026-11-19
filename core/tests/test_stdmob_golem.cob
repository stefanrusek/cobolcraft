*> Implementation test (lane buggolem, T42901 to T42907; 19 section 19, 44 part 3 section 6, 17 section 4.6): the iron golem of a standard world on a stone floor, run through
*> real CORE-TICKs (operator report of try15: "iron golem has no AI and can't be killed"). Cases:
*>  - a player's hit does not move a golem (knockback_resistance 1.0: strength x (1 - 1) = 0, no hop), and still moves a cow;
*>  - a golem dies of repeated hits of an iron sword, and leaves 3 to 5 iron ingots (poppies 0 to 2) on the ground;
*>  - a golem hit by a player turns on that player (HurtByTarget, anger 20 to 39 seconds) unless it was built from the pattern (PlayerCreated);
*>  - GOLEM-BUILD sets PlayerCreated, a MOB-SPAWN golem has it clear;
*>  - a creeper is no target of the golem (canAttack), a zombie is;
*>  - OfferFlower: at night, with the roll 0 of nextInt(8000), the golem holds the flower for 400 ticks (entity event 11, then 34), never by day;
*>  - an idle golem strolls (GolemRandomStrollInVillage falls back to anywhere outside a village, speed modifier 0.6, interval 240).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-GOLEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-MOBKEY              PIC X(24).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-GOLEM               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-POPPY               BINARY-LONG.
 01 WS-INGOTS              BINARY-LONG.
 01 WS-POPPIES             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THIRTEEN            BINARY-LONG VALUE 13.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-START-X             FLOAT-LONG.
 01 WS-START-Z             FLOAT-LONG.
 01 WS-PREV-X              FLOAT-LONG.
 01 WS-PREV-Z              FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-MAX-STEP            FLOAT-LONG.
 01 WS-LENGTH              FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-ROLL-NONE           BINARY-LONG VALUE 1.
 01 WS-ROLL-HIT            BINARY-LONG VALUE 0.
 01 WS-TIME-DAY            BINARY-LONG VALUE 6000.
 01 WS-TIME-NIGHT          BINARY-LONG VALUE 18000.
 01 WS-TEXT                PIC X(4096).
 01 WS-NEEDLE              PIC X(40).
 01 WS-EDIT-ID             PIC -(9)9.
 01 WS-EDIT-K              PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-VILLAGER            BINARY-LONG.
 01 WS-CREEPER             BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-GOLEM-TYPE          BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(24).
 01 WS-KEY48               PIC X(48).
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/mobs2-registry".
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE 2 TO BW-DIFFICULTY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     PERFORM VARYING WS-X FROM -24 BY 1 UNTIL WS-X > 24
         PERFORM VARYING WS-Z FROM -24 BY 1 UNTIL WS-Z > 24
             COMPUTE WS-K = WS-CX + WS-X
             COMPUTE WS-I = WS-CZ + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-K WS-FLOOR WS-I WS-STONE
             PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 4
                 COMPUTE WS-ID = WS-FLOOR + WS-Y
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-K WS-ID WS-I WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "minecraft:iron_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-INGOT WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:poppy" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-POPPY WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:iron_sword" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 6000 TO CW-TIME
     PERFORM TEST-KNOCKBACK
     PERFORM TEST-BUILD-FLAG
     PERFORM TEST-KILL-AND-DROPS
     PERFORM TEST-RETALIATE
     PERFORM TEST-TARGETS
     PERFORM TEST-FLOWER
     PERFORM TEST-STROLL
     STOP RUN.

 TEST-KNOCKBACK.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     PERFORM HIT-MOB
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(FUNCTION ABS(EN-VX(WS-GOLEM)) * 1000) + FUNCTION INTEGER(FUNCTION ABS(EN-VZ(WS-GOLEM)) * 1000)
         + FUNCTION INTEGER(FUNCTION ABS(EN-VY(WS-GOLEM)) * 1000)
     MOVE "acceptance US15 17§4.6 an iron golem (knockback_resistance 1.0) is not pushed by a player's hit" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     MOVE "acceptance US15 17§4.6 the hit still hurts the golem (iron sword 6 of 100)" TO WS-CASE
     MOVE 94 TO WS-EXPECT
     MOVE EN-HEALTH(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM
     MOVE "cow" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     PERFORM HIT-MOB
     COMPUTE WS-N = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-GOLEM) ** 2 + EN-VZ(WS-GOLEM) ** 2) * 100)
     MOVE "acceptance US15 17§4.6 a cow (no resistance) is still pushed by a hit (at least 0.4 a tick)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-N >= 40
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM
*>   A cow standing on the ground is thrown up by 0.4 (17 section 4.6 step 5) and a sprinting player adds 0.5 along the facing (K), a golem takes neither.
     MOVE "cow" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     PERFORM KEEP-ALIVE
     CALL "TEST-TICKS" USING WS-THIRTEEN
     MOVE 1 TO PL-SPRINTING(WS-PLAYER)
     PERFORM HIT-MOB
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)
     MOVE "acceptance US15 17§4.6 a cow on the ground is thrown up by a hit (vertical speed 0.4)" TO WS-CASE
     MOVE 400 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-VY(WS-GOLEM) * 1000 + 0.5)
     PERFORM CHECK-N
     COMPUTE WS-N = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-GOLEM) ** 2 + EN-VZ(WS-GOLEM) ** 2) * 100)
     MOVE "acceptance US15 17§4.6 a sprinting hit adds 0.5 along the facing (0.4 away + 0.5 ahead: at least 0.6)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-N >= 60
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     PERFORM KEEP-ALIVE
     CALL "TEST-TICKS" USING WS-THIRTEEN
     MOVE 1 TO PL-SPRINTING(WS-PLAYER)
     PERFORM HIT-MOB
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)
*>   (A mob standing on the ground has the vertical speed of gravity, so only the horizontal motion and a rise are compared.)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(FUNCTION ABS(EN-VX(WS-GOLEM)) * 1000) + FUNCTION INTEGER(FUNCTION ABS(EN-VZ(WS-GOLEM)) * 1000)
     IF EN-VY(WS-GOLEM) > 0
         ADD 1000 TO WS-OBSERVE
     END-IF
     MOVE "acceptance US15 17§4.6 a sprinting hit does not move an iron golem either" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 TEST-BUILD-FLAG.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE "acceptance US15 19§19 a golem spawned by MOB-SPAWN (a village summon) is not player created" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-PLAYER-MADE(WS-MOB) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM BUILD-GOLEM
     MOVE "acceptance US15 19§19 a golem built from the pumpkin pattern is player created" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-PLAYER-MADE(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 TEST-KILL-AND-DROPS.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE 1 TO EN-PLAYER-MADE(WS-GOLEM)
     MOVE 0 TO WS-HITS
     PERFORM KEEP-ALIVE
     CALL "TEST-TICKS" USING WS-THIRTEEN
     PERFORM UNTIL WS-HITS >= 60 OR EN-USED(WS-GOLEM) = 0 OR EN-HEALTH(WS-GOLEM) = 0
         ADD 1 TO WS-HITS
         PERFORM HIT-MOB
         IF EN-HEALTH(WS-GOLEM) > 0
             CALL "TEST-TICKS" USING WS-THIRTEEN
         END-IF
     END-PERFORM
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-USED(WS-GOLEM) = 0 OR EN-HEALTH(WS-GOLEM) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE "acceptance US15 19§19 an iron golem dies of 60 hits of an iron sword at most (100 health, 6 a hit)" TO WS-CASE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§19 it took 17 hits (6 x 17 = 102)" TO WS-CASE
     MOVE 17 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
*>   The player steps away so that nothing is picked up while the drops are counted.
     PERFORM RESPAWN-PLAYER
     PERFORM KEEP-ALIVE
     CALL "TEST-TICKS" USING WS-THIRTEEN
     MOVE 0 TO WS-INGOTS WS-POPPIES
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = CR-LOOSE-ITEM
             IF EN-ITEM(WS-N) = WS-INGOT
                 ADD EN-ITEM-COUNT(WS-N) TO WS-INGOTS
             END-IF
             IF EN-ITEM(WS-N) = WS-POPPY
                 ADD EN-ITEM-COUNT(WS-N) TO WS-POPPIES
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§19 the golem leaves 3 to 5 iron ingots (loot table: uniform 3 to 5)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-INGOTS >= 3 AND WS-INGOTS <= 5
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§19 the golem leaves 0 to 2 poppies (loot table: uniform 0 to 2)" TO WS-CASE
     MOVE 0 TO WS-OBSERVE
     IF WS-POPPIES <= 2
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N.

 TEST-RETALIATE.
*>   A summoned golem (no PlayerCreated flag) turns on the player who hit it and hurts them within 200 ticks.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE WS-HEALTH0 TO PL-HEALTH(WS-PLAYER)
     PERFORM HIT-MOB
     MOVE "acceptance US15 44p3§6 a golem that was hit by a player is angry at that player (anger 400 to 780 ticks)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-ANGER(WS-GOLEM) >= 400 AND EN-ANGER(WS-GOLEM) <= 780 AND EN-GOLEM-PL(WS-GOLEM) = WS-PLAYER
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR PL-HEALTH(WS-PLAYER) < WS-HEALTH0 OR PL-STATE(WS-PLAYER) NOT = PS-ALIVE
         PERFORM KEEP-ALIVE
         CALL "TEST-TICKS" USING WS-ONE
     END-PERFORM
     MOVE "acceptance US15 44p3§6 the angry golem walks up to the player and hits them (health falls within 200 ticks)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH0 OR PL-STATE(WS-PLAYER) NOT = PS-ALIVE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM
     PERFORM RESPAWN-PLAYER
*>   The anger ends when the player is no valid target any more (creative mode) or when its player row is lost.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE 300 TO EN-ANGER(WS-GOLEM)
     MOVE WS-PLAYER TO EN-GOLEM-PL(WS-GOLEM)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-HX WS-HZ WS-WALK
     CALL "GOLEM-TICK" USING WS-GOLEM WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44p3§6 a golem is no longer angry at a player who turned creative" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-ANGER(WS-GOLEM) + EN-GOLEM-PL(WS-GOLEM)
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 5 TO EN-ANGER(WS-GOLEM)
     MOVE 0 TO EN-GOLEM-PL(WS-GOLEM)
     CALL "GOLEM-TICK" USING WS-GOLEM WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44p3§6 anger with no player row ends at once" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-ANGER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM
*>   A built golem (PlayerCreated) never targets a player, even one that hit it (19 section 19, 44 part 3 section 6).
     PERFORM BUILD-GOLEM
     MOVE WS-HEALTH0 TO PL-HEALTH(WS-PLAYER)
     PERFORM HIT-MOB
     MOVE "acceptance US15 44p3§6 a player-created golem is not angry at the player who hit it" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-ANGER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         PERFORM KEEP-ALIVE
         CALL "TEST-TICKS" USING WS-ONE
     END-PERFORM
     MOVE "acceptance US15 44p3§6 the player-created golem leaves the player unhurt for 200 ticks" TO WS-CASE
     MOVE WS-HEALTH0 TO WS-EXPECT
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 TEST-TARGETS.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM RESPAWN-PLAYER
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE 1 TO EN-PLAYER-MADE(WS-GOLEM)
     MOVE "creeper" TO WS-MOBKEY
     MOVE 4 TO WS-X
     PERFORM SPAWN-MOB-AT
     MOVE WS-MOB TO WS-CREEPER
     MOVE 0 TO WS-HX WS-HZ WS-WALK
     CALL "GOLEM-TICK" USING WS-GOLEM WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44p3§6 a creeper is no target of an iron golem (canAttack)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-FOE(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "zombie" TO WS-MOBKEY
     MOVE -5 TO WS-X
     PERFORM SPAWN-MOB-AT
     MOVE WS-MOB TO WS-ZOMBIE
     CALL "GOLEM-TICK" USING WS-GOLEM WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44p3§6 a zombie is a target of an iron golem (an Enemy that is not a creeper)" TO WS-CASE
     MOVE WS-ZOMBIE TO WS-EXPECT
     MOVE EN-FOE(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     CALL "ENTITY-REMOVE" USING WS-CREEPER
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 TEST-FLOWER.
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE "villager" TO WS-MOBKEY
     MOVE 3 TO WS-X
     PERFORM SPAWN-MOB-AT
     MOVE WS-MOB TO WS-VILLAGER
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
*>   By day the goal is not usable, whatever the roll.
     MOVE WS-TIME-DAY TO CW-TIME
     CALL "GOLEM-OFFER-TICK" USING WS-GOLEM WS-ROLL-HIT
     MOVE "acceptance US15 19§19 OfferFlower: not by day (isBrightOutside)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-GOLEM-FLOWER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-TIME-NIGHT TO CW-TIME
     CALL "GOLEM-OFFER-TICK" USING WS-GOLEM WS-ROLL-NONE
     MOVE "acceptance US15 19§19 OfferFlower: a roll other than 0 of nextInt(8000) starts nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-GOLEM-FLOWER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "GOLEM-OFFER-TICK" USING WS-GOLEM WS-ROLL-HIT
     MOVE "acceptance US15 19§19 OfferFlower: at night, roll 0 and a villager within 6 starts the 400 tick pose" TO WS-CASE
     MOVE 400 TO WS-EXPECT
     MOVE EN-GOLEM-FLOWER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     MOVE EN-ID(WS-GOLEM) TO WS-ID
     MOVE 11 TO WS-K
     PERFORM FIND-EVENT
     MOVE "acceptance US15 19§19 OfferFlower: entity event 11 goes to the viewers" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 399
         CALL "GOLEM-OFFER-TICK" USING WS-GOLEM WS-ROLL-NONE
     END-PERFORM
     MOVE "acceptance US15 19§19 OfferFlower: one tick left after 399 ticks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-GOLEM-FLOWER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     CALL "GOLEM-OFFER-TICK" USING WS-GOLEM WS-ROLL-NONE
     MOVE "acceptance US15 19§19 OfferFlower: the pose ends after 400 ticks" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-GOLEM-FLOWER(WS-GOLEM) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     MOVE 34 TO WS-K
     PERFORM FIND-EVENT
     MOVE "acceptance US15 19§19 OfferFlower: entity event 34 ends the pose at the viewers" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-VILLAGER
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 TEST-STROLL.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "iron_golem" TO WS-MOBKEY
     PERFORM SPAWN-MOB
     MOVE WS-MOB TO WS-GOLEM
     MOVE 6000 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     MOVE EN-X(WS-GOLEM) TO WS-START-X
     MOVE EN-Z(WS-GOLEM) TO WS-START-Z
     MOVE 0 TO WS-LENGTH WS-MAX-STEP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         MOVE EN-X(WS-GOLEM) TO WS-PREV-X
         MOVE EN-Z(WS-GOLEM) TO WS-PREV-Z
         PERFORM KEEP-ALIVE
         CALL "TEST-TICKS" USING WS-ONE
         COMPUTE WS-STEP = FUNCTION SQRT((EN-X(WS-GOLEM) - WS-PREV-X) ** 2 + (EN-Z(WS-GOLEM) - WS-PREV-Z) ** 2)
         ADD WS-STEP TO WS-LENGTH
         IF WS-STEP > WS-MAX-STEP
             MOVE WS-STEP TO WS-MAX-STEP
         END-IF
*>       Keep it on the floor: back to the centre when it has gone 12 blocks.
         IF FUNCTION ABS(EN-X(WS-GOLEM) - WS-START-X) > 12 OR FUNCTION ABS(EN-Z(WS-GOLEM) - WS-START-Z) > 12
             MOVE WS-START-X TO EN-X(WS-GOLEM)
             MOVE WS-START-Z TO EN-Z(WS-GOLEM)
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§19 an idle iron golem strolls (GolemRandomStrollInVillage falls back to anywhere): 1500 ticks cover more than 5 blocks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LENGTH > 5
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
*>   The stroll speed modifier 0.6: (0.25 x 0.6) squared / 0.454 = 0.0496 blocks a tick at most (a little more on the tick of a start).
     MOVE "acceptance US15 19§19 the stroll goes at modifier 0.6, not the chase speed (a tick covers at most 0.06 blocks)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-MAX-STEP > 0 AND WS-MAX-STEP <= 0.06
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-GOLEM.

 SPAWN-MOB.
     MOVE 0 TO WS-X
     PERFORM SPAWN-MOB-AT.

*> A mob WS-X blocks east of the centre of the floor.
 SPAWN-MOB-AT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-MOBKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-X
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-MOB.

*> The player stands 1.5 blocks east of the mob in WS-GOLEM and attacks it once.
 HIT-MOB.
     PERFORM KEEP-ALIVE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-GOLEM) + 1.5
     MOVE EN-Z(WS-GOLEM) TO PL-Z(WS-PLAYER)
     MOVE EN-Y(WS-GOLEM) TO PL-Y(WS-PLAYER)
     MOVE EN-ID(WS-GOLEM) TO WS-ID
     CALL "TEST-ATTACK" USING WS-CONN WS-ID.

 KEEP-ALIVE.
     COMPUTE CN-KA-DEADLINE(WS-CONN) = CW-TICKS + 300
     MOVE 0 TO CN-KA-PENDING(WS-CONN).

 RESPAWN-PLAYER.
     MOVE WS-HEALTH0 TO PL-HEALTH(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 20.5
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 20.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1.

*> Builds an iron golem with GOLEM-BUILD on the centre column (the T along x) and puts its row in WS-GOLEM.
 BUILD-GOLEM.
     MOVE WS-CX TO WS-BX
     MOVE WS-CZ TO WS-BZ
     MOVE "iron_block" TO WS-BLOCK-KEY
     COMPUTE WS-Y = WS-FLOOR + 1
     PERFORM PUT-BLOCK
     COMPUTE WS-Y = WS-FLOOR + 2
     PERFORM PUT-BLOCK
     COMPUTE WS-BX = WS-CX - 1
     PERFORM PUT-BLOCK
     COMPUTE WS-BX = WS-CX + 1
     PERFORM PUT-BLOCK
     MOVE WS-CX TO WS-BX
     MOVE "carved_pumpkin" TO WS-BLOCK-KEY
     COMPUTE WS-Y = WS-FLOOR + 3
     PERFORM PUT-BLOCK
     CALL "GOLEM-BUILD" USING WS-DIM WS-BX WS-Y WS-BZ
     MOVE "minecraft:iron_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GOLEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-GOLEM
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = WS-GOLEM-TYPE
             MOVE WS-N TO WS-GOLEM
         END-IF
     END-PERFORM.

 PUT-BLOCK.
     MOVE SPACES TO WS-KEY48
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-BLOCK-KEY) DELIMITED BY SIZE INTO WS-KEY48
     CALL "WORLDSIM-FIND-BLOCK" USING WS-KEY48 WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-STATE.

*> WS-OBSERVE 1 when the drained text WS-TEXT holds "event <WS-ID> <WS-K>".
 FIND-EVENT.
     MOVE 0 TO WS-OBSERVE
     MOVE SPACES TO WS-NEEDLE
     MOVE WS-ID TO WS-EDIT-ID
     MOVE WS-K TO WS-EDIT-K
     STRING "event " FUNCTION TRIM(WS-EDIT-ID) " " FUNCTION TRIM(WS-EDIT-K) DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE)
     IF WS-HITS > 0
         MOVE 1 TO WS-OBSERVE
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STDMOB-GOLEM.
 COPY CORETEST.
