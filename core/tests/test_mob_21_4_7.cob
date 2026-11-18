*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.7 with doc 44 part 7 sections 8 and 9.1): the axolotl. The row (health 14, attack 2, category axolotls), the
*> spawn predicate (clay below, nothing else), the spawn variants (two common draws, one of them picked, never blue) and the baby rule of a pack (members 3 on), the air supply (6000, dry out
*> for 2 damage at -20), the play-dead test (each step of 8.3), play dead itself (no movement, Regeneration 200 ticks, over after 200 ticks), hunting (a fish within 8 blocks in water, the
*> hunting cooldown of 2400 ticks after a fight, the always hostile drowned during it) and the supporting effects of a kill on a player (8.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-AXOLOTL             BINARY-LONG.
 01 WS-COD                 BINARY-LONG.
 01 WS-DROWNED             BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FISH                BINARY-LONG.
 01 WS-FOE                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-DA                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-MAXHP               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG OCCURS 5 TIMES.
 01 WS-PAIR                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CLAY                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-FATIGUE             BINARY-LONG VALUE 3.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 600.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-STATE               PIC X(8).
 01 WS-HEALTH-BEFORE       BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:axolotl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-AXOLOTL WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:drowned" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DROWNED WS-ENTITY-ROW WS-STATUS
*>   The row.
     CALL "STDMOB-INDEX" USING WS-AXOLOTL WS-M
     MOVE "acceptance US15 21§4.7 the axolotl has a mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-M > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.7 max health 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.7 attack damage 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SM-ATTACK(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.7 spawn category AXOLOTLS (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     CALL "MS6-ROW-CAT" USING WS-M TL-OBSERVED-N
     PERFORM CHECK-N
*>   The play-dead test of 44-7 section 8.3: draws A (nextInt(3)) and B (nextInt(3)), damage, health before, max health, in water, source present, already playing dead.
     MOVE 0 TO WS-DA
     MOVE 0 TO WS-DB
     MOVE 1 TO WS-DMG
     MOVE 14 TO WS-HP WS-MAXHP
     MOVE 1 TO WS-WATER WS-SRC
     MOVE 0 TO WS-DEAD
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 draw A 0, draw B below the damage, in water, a source: play dead" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO WS-DA
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 draw A not 0: no" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO WS-DA
     MOVE 1 TO WS-DB
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 draw B not below the damage and health at least half: no" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 6 TO WS-HP
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 draw B not below the damage but health under half (6 of 14): play dead" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 7 TO WS-HP
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 health exactly half (7 of 14) is not under half: no" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 6 TO WS-HP
     MOVE 6 TO WS-DMG
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 a hit that would kill (damage 6, health 6): no" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 5 TO WS-DMG
     MOVE 0 TO WS-WATER
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 out of water: no" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO WS-WATER
     MOVE 0 TO WS-SRC
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 a source without an entity: no" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO WS-SRC
     MOVE 1 TO WS-DEAD
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB WS-DMG WS-HP WS-MAXHP WS-WATER WS-SRC WS-DEAD WS-OK
     MOVE "acceptance US15 44-7§8.3 already playing dead: no" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The spawn predicate: the block below is clay.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:clay" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-CLAY
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BY = WS-Y0 + 3
     COMPUTE WS-BZ = WS-Z0 + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-CLAY
     COMPUTE WS-BY = WS-Y0 + 4
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§4.7 spawn rule: clay below the position passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-BY = WS-Y0 + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-Y0 + 4
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§4.7 spawn rule: stone below does not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Spawn variants: 150 seeds, the variant (EN-VARIANT = 1 + id) is lucy, wild, gold or cyan, never blue, and all four occur; the pair is two common variants.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO WS-SEEN(WS-I)
     END-PERFORM
     MOVE 0 TO WS-BAD
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 6.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF EN-VARIANT(WS-ROW) < 1 OR EN-VARIANT(WS-ROW) > 4
             ADD 1 TO WS-BAD
         ELSE
             ADD 1 TO WS-SEEN(EN-VARIANT(WS-ROW))
         END-IF
         IF EN-MOBAGE(WS-ROW) < 0
             ADD 1 TO WS-BAD
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-7§8.1 a single spawn is an adult of a common variant, never blue" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§8.1 all four common variants occur over 150 seeds (each above 15)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-SEEN(WS-I) <= 15
             MOVE 0 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     PERFORM CHECK-N
*>   A pack of 6: the first two are adults, the others babies of age -24000; every member has one of the first member's two variants.
     MOVE 77 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-FIRST
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-FIRST
     MOVE WS-FIRST TO WS-ROW
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-DEAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         CALL "AQUA-PACK" USING XR-STATE WS-FIRST WS-ROW WS-I
         IF WS-I >= 2 AND EN-MOBAGE(WS-ROW) NOT = -24000
             ADD 1 TO WS-BAD
         END-IF
         IF WS-I < 2 AND EN-MOBAGE(WS-ROW) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
         MOVE EN-WOOL(WS-FIRST) TO WS-PAIR
         COMPUTE WS-A = FUNCTION MOD(WS-PAIR, 8) + 1
         COMPUTE WS-B = FUNCTION INTEGER(WS-PAIR / 8) + 1
         IF EN-VARIANT(WS-ROW) NOT = WS-A AND EN-VARIANT(WS-ROW) NOT = WS-B
             ADD 1 TO WS-DEAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§8.1 pack members 3 and later are babies (age -24000), members 1 and 2 adults" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§8.1 every member of the pack has one of the first member's two variants" TO TL-CASE
     MOVE WS-DEAD TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Air: out of water on the dry ground 12.5 blocks east of the tank; 6000 air, at the 6020th dry tick the air is 0 again and it takes 2 (dry out).
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 1
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 6018 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§8.4 the air lasts 6000 ticks: no damage at dry tick 6019 (health 14)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§8.4 at air -20 (dry tick 6020) it takes 2 damage of dry out (14 to 12)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§8.4 and the air is 0 again (6000 dry ticks counted)" TO TL-CASE
     MOVE 6000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Play dead: no movement for the first 150 ticks, Regeneration for 200 ticks at amplifier 0, moving again after 200 ticks.
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "AXOLOTL-PLAY-DEAD" USING WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE EN-X(WS-ROW) TO WS-X
     MOVE EN-Z(WS-ROW) TO WS-Z
     CALL "MEF-LEVEL" USING EN-ID(WS-ROW) WS-REGEN WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-7§8.3 play dead gives Regeneration amplifier 0 (level 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§8.3 for about 200 ticks (between 195 and 200 left after one tick)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TICKS >= 195 AND WS-TICKS <= 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-7§8.3 a playing-dead axolotl does not move for 150 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-X(WS-ROW) - WS-X) < 0.5 AND FUNCTION ABS(EN-Z(WS-ROW) - WS-Z) < 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "AXOLOTL-PLAYING-DEAD" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§8.3 it is still playing dead at tick 151" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     CALL "AXOLOTL-PLAYING-DEAD" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§8.3 and has stopped by tick 211" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Hunting: a cod 2 blocks away in the tank; the axolotl (2 damage a hit, 20 ticks apart) kills the cod (3 health), then the hunting cooldown of 2400 ticks runs.
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-ROW TO WS-A
     COMPUTE WS-X = WS-X0 + 6.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-FISH
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-B
     MOVE WS-PLAYER TO EN-KILLER(WS-FISH)
     MOVE 2000 TO EN-KILLER-AGE(WS-FISH)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR EN-HEALTH(WS-FISH) = 0
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-FISH
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 21§4.7 the axolotl hunts the cod within 8 blocks and kills it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-FISH) TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-7§8.3 when the fight ends the hunting cooldown is set for 2400 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-WAKE(WS-A) >= 2390 AND EN-WAKE(WS-A) <= 2400
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   The supporting effects (8.5): the cod was last hurt by the player (still within 20 blocks of the axolotl): Regeneration 100 ticks, Mining Fatigue removed.
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-REGEN WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-7§8.5 the player who killed the target near the axolotl gets Regeneration for 100 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEVEL = 1 AND WS-TICKS > 90 AND WS-TICKS <= 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   During the cooldown another cod is left alone; a drowned (always hostile) is attacked.
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-FISH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-FISH
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-7§9.1 during the hunting cooldown a cod is not a target (health 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-FISH) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "MOB-SPAWN" USING WS-DIM WS-DROWNED WS-X WS-Y WS-Z WS-YAW WS-FOE
     MOVE EN-HEALTH(WS-FOE) TO WS-HEALTH-BEFORE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-7§9.1 a drowned in water within 8 blocks is attacked even during the cooldown" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-FOE) < WS-HEALTH-BEFORE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-7.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
