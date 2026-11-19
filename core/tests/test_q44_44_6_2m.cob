*> The piglin hostility engine over mobs (docs/protocol/44-residual-mob-questions-6-nether.md sections 1, 2.2 to 2.8, 4.1 to 4.3, 6.3, 9.4, V5 to V8; lane 002-lane-p49l):
*> the retaliation distance rule, hoglinsOutnumberPiglins, the sensors' visible adult lists and counts, a piglin or hoglin hit by a mob (wasHurtBy), the zoglin's finder, the nemesis
*> of piglins and wither skeletons and the hunt group rule. The brain memories are re-derived as observable state (EN-FOE, PG-AVOID, PH-TIMER).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-2M.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY HUNT.
 COPY PGBRAIN.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-HOGS2               BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-D2-OTHER            FLOAT-LONG.
 01 WS-D2-CUR              FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-AVOIDING            BINARY-LONG.
 01 WS-K24                 PIC X(24).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1000 TO CW-TICKS
*>   Section 1: isOtherTargetMuchFurtherAwayThanCurrentAttackTarget with 4.0 (worked example 2 of section 11.1).
     MOVE 100 TO WS-D2-OTHER
     MOVE 36 TO WS-D2-CUR
     CALL "PGAI-MUCH-FURTHER" USING WS-ONE WS-D2-OTHER WS-D2-CUR WS-FLAG
     MOVE "acceptance 44-6§1 other at 100 vs target at 36: much further" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 49 TO WS-D2-OTHER
     CALL "PGAI-MUCH-FURTHER" USING WS-ONE WS-D2-OTHER WS-D2-CUR WS-FLAG
     MOVE "acceptance 44-6§1 other at 49 vs target at 36 (49 > 52 is false): not further" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-D2-OTHER
     CALL "PGAI-MUCH-FURTHER" USING WS-NO WS-D2-OTHER WS-D2-CUR WS-FLAG
     MOVE "acceptance 44-6§1 without an attack target: false" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.6 and V6: hoglinsOutnumberPiglins is hoglins > piglins + 1.
     CALL "PGAI-OUTNUMBER" USING WS-ONE WS-TWO WS-THREE WS-FLAG
     MOVE "acceptance 44-6§V6 counts (piglin 2, hoglin 3): not outnumbered" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGAI-OUTNUMBER" USING WS-ONE WS-TWO WS-FOUR WS-FLAG
     MOVE "acceptance 44-6§V6 counts (piglin 2, hoglin 4): outnumbered" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 6.2: piglinsOutnumberHoglins (the hoglin's own formula) is piglins > hoglins + 1.
     CALL "PGAI-OUTNUMBER" USING WS-TWO WS-FOUR WS-HOGS2 WS-FLAG
     MOVE "acceptance 44-6§6.2 hoglin sees piglins 4, hoglins 2: outnumbered" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGAI-OUTNUMBER" USING WS-TWO WS-THREE WS-HOGS2 WS-FLAG
     MOVE "acceptance 44-6§6.2 hoglin sees piglins 3, hoglins 2: not outnumbered" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 4.1: the piglin sensor. A looks at another adult piglin, a brute, a baby piglin, two adult hoglins and a baby hoglin; it is not in its own lists.
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 4
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 2
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     MOVE -10000 TO EN-MOBAGE(WS-D)
     COMPUTE WS-Z = WS-Z0 + 5
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z WS-E
     COMPUTE WS-Z = WS-Z0 + 7
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z WS-F
     COMPUTE WS-Z = WS-Z0 - 1
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z WS-G
     MOVE -10000 TO EN-MOBAGE(WS-G)
     CALL "PGAI-SENSE" USING WS-A WS-ONE WS-NP WS-NH WS-HUNT WS-NEAR
     MOVE "acceptance 44-6§4.1 visible adult piglin list: the piglin and the brute, not itself nor the baby" TO TL-CASE
     MOVE WS-TWO TO TL-EXPECTED-N
     MOVE WS-NP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§4.1 visible adult hoglin count: both adults, not the baby" TO TL-CASE
     MOVE WS-TWO TO TL-EXPECTED-N
     MOVE WS-NH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§4.1 the nearest adult hoglin is the huntable one" TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-HUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGAI-SENSE" USING WS-A WS-TWO WS-NP WS-NH WS-HUNT WS-NEAR
     MOVE "acceptance 44-6§4.3 hoglin sensor counts adult piglins only (a brute is no Piglin)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-NP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§4.3 hoglin sensor: the first adult piglin is the nearest" TO TL-CASE
     MOVE WS-B TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A wall between A and the far hoglin hides it from the sensor (visible entities only).
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE
     COMPUTE WS-BY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE
     COMPUTE WS-BY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE
     CALL "PGAI-SENSE" USING WS-A WS-ONE WS-NP WS-NH WS-HUNT WS-NEAR
     MOVE "acceptance 44-6§4.1 a hoglin behind a wall is not visible" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-NH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.3 and 2.6: a piglin hit by a hoglin while hoglins outnumber the piglins retreats (AVOID_TARGET, no foe, no hunting for a while) and tells the other visible piglins.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 1
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 2
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     COMPUTE WS-X = WS-X0 + 3
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-E
     MOVE WS-C TO EN-FOE(WS-A)
     MOVE EN-ID(WS-C) TO EN-FOE-ID(WS-A)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-C
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§2.3 step 7 hoglins 3 > piglins 1 + 1: the hit piglin retreats" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.6 the retreat erases its foe" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PH-FIND" USING EN-ID(WS-A) WS-SLOT
     MOVE 0 TO WS-FLAG
     IF WS-SLOT > 0
         IF PH-TIMER(WS-SLOT) >= 600 AND PH-TIMER(WS-SLOT) <= 2400
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     MOVE "acceptance 44-6§2.6 and no hunting for 600 to 2400 ticks" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOIDING" USING WS-B WS-AVOIDING
     MOVE "acceptance 44-6§2.6 broadcastRetreat: the other visible piglin retreats too" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.3 step 8 and 2.5: not outnumbered, the piglin retaliates against its attacker and the nearby piglins that can hunt join in; a brute does not hunt a hoglin.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 - 4
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-F
     COMPUTE WS-X = WS-X0 + 1
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-C
     MOVE "acceptance 44-6§2.3 step 8 hoglins 1 vs piglins 1 + 1: retaliates, the attacker is the foe" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§2.3 step 8 it does not retreat" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.5 broadcastAngerTarget: the other piglin takes the hoglin" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.5 a brute never hunts a hoglin: skipped" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-F) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.3 step 1: a piglin attacker is ignored.
     MOVE 0 TO EN-FOE(WS-A) EN-FOE-ID(WS-A)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-B
     MOVE "acceptance 44-6§2.3 step 1 hit by a piglin: ignored" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.7: a brute ignores any piglin or brute attacker, and retaliates against anything else.
     CALL "PGAI-HURT-BY-MOB" USING WS-F WS-A
     MOVE "acceptance 44-6§2.7 a brute hit by a piglin: ignored" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-F) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGAI-HURT-BY-MOB" USING WS-F WS-C
     MOVE "acceptance 44-6§2.7 a brute hit by a hoglin retaliates" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-F) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.4 step 3 (worked example 2): a foe at 6 blocks keeps the piglin against an attacker at 10, an attacker at 7 retargets it.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 6
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 - 10
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     MOVE WS-C TO EN-FOE(WS-A)
     MOVE EN-ID(WS-C) TO EN-FOE-ID(WS-A)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.4 attacker at 10 vs foe at 6: the foe stays" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-D) = WS-X0 - 7
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.4 attacker at 7 vs foe at 6: retargeted" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.3 steps 2 and 3: hit by a mob while admiring, the ingot is lost and ADMIRING_DISABLED is not set (only players set it).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     MOVE "hoglin" TO WS-K24
     COMPUTE WS-X = WS-X0 - 5
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     MOVE 80 TO EN-ADMIRE(WS-A)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.3 steps 2-3 admiring ends when hit by a mob" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.3 step 4 a mob does not set ADMIRING_DISABLED" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-ADMIRE-OFF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 5: a retreat from a hoglin is cancelled by a hit of a different kind of creature, which is then retaliated against.
     CALL "PGAI-RETREAT" USING WS-A WS-C
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§2.3 step 5 hit by another kind: the retreat ends" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.3 step 8 and the new attacker is the foe" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 6: a baby avoids its attacker for 100 ticks and the others are told.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE -10000 TO EN-MOBAGE(WS-A)
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 3
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     CALL "PGB-SLOT" USING EN-ID(WS-A) WS-NO WS-SLOT
     MOVE 0 TO WS-FLAG
     IF WS-SLOT > 0
         IF PG-AVOID(WS-SLOT) = 100 AND PG-AVOID-KIND(WS-SLOT) = 3
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     MOVE "acceptance 44-6§2.3 step 6 avoid timer 100, kind 3" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.3 step 6 the baby itself gets no anger" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.3 step 6 broadcastAngerTarget: the adult takes the attacker" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 6.3 and V8: a zoglin takes the closest visible living entity that is no zoglin and no creeper, the villager here.
     CALL "T-CLEAR"
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 2
     MOVE "creeper" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 3
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 5
     MOVE "villager" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     COMPUTE WS-X = WS-X0 + 8
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-E
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-A) WS-M
     MOVE 0 TO EN-TARGET(WS-A)
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§V8 zoglin with a creeper, a zoglin and a villager: the villager" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOE(WS-A) EN-FOE-ID(WS-A)
     COMPUTE WS-X = WS-X0 + 1
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-F
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.3 a zoglin attacks anything attackable: the nearer piglin" TO TL-CASE
     MOVE WS-F TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.2 step 4 and 4.1 nemesis: a piglin and a brute take a visible wither skeleton, a baby does not; step 1: near a zombified piglin there is no target.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 2
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     MOVE -10000 TO EN-MOBAGE(WS-B)
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 6
     MOVE "wither_skeleton" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-A) WS-M
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.2 step 4 an adult piglin takes the visible wither skeleton" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-B) WS-M
     CALL "MOBVS-TICK" USING WS-B WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.2 a baby piglin never starts an attack" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-C) WS-M
     CALL "MOBVS-TICK" USING WS-C WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.7 step 3 a brute takes the visible wither skeleton" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOE(WS-A) EN-FOE-ID(WS-A)
     MOVE WS-X0 TO WS-X
     MOVE 1 TO WS-FLAG
     CALL "PGB-AVOID-SET" USING WS-A WS-ONE WS-X WS-Z0 WS-FLAG
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-A) WS-M
     MOVE 30 TO WS-FLAG
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.2 step 1 avoiding a zombified creature: no target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 9.4: a wither skeleton also targets a piglin (the extra goal), the nearest one.
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-D) WS-M
     CALL "MOBVS-TICK" USING WS-D WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§9.4 a wither skeleton takes the nearest piglin" TO TL-CASE
     MOVE WS-A TO TL-EXPECTED-N
     MOVE EN-FOE(WS-D) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.8: StartHuntingHoglin waits while a visible adult piglin has HUNTED_RECENTLY, then the group hunts together and pauses together.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 5
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-E
     CALL "PIGLIN-HUNT-STEP" USING WS-B
     CALL "PIGLIN-HUNT-STEP" USING WS-A
     CALL "PH-FIND" USING EN-ID(WS-A) WS-SLOT
     MOVE 0 TO PH-TIMER(WS-SLOT)
     CALL "PH-FIND" USING EN-ID(WS-B) WS-SLOT
     MOVE 100 TO PH-TIMER(WS-SLOT)
     CALL "PIGLIN-HUNT-STEP" USING WS-A
     MOVE "acceptance 44-6§2.8 a visible piglin hunted recently: no hunt" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PH-TIMER(WS-SLOT)
     CALL "PIGLIN-HUNT-STEP" USING WS-A
     MOVE "acceptance 44-6§2.8 nobody hunted recently: the hunter takes the hoglin" TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.8 broadcastAngerTarget: the other piglin hunts it too" TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PH-FIND" USING EN-ID(WS-A) WS-SLOT
     MOVE 0 TO WS-FLAG
     IF PH-TIMER(WS-SLOT) >= 600 AND PH-TIMER(WS-SLOT) <= 2400
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§2.8 the hunter's HUNTED_RECENTLY is set" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PH-FIND" USING EN-ID(WS-B) WS-SLOT
     MOVE 0 TO WS-FLAG
     IF PH-TIMER(WS-SLOT) >= 600 AND PH-TIMER(WS-SLOT) <= 2400
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§2.8 every visible adult piglin gets HUNTED_RECENTLY" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A listener that is angry at a player takes a mob that is nearer (setAngerTargetIfCloserThanCurrent) and keeps a player that is nearer than the mob.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 4
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     MOVE WS-PLAYER TO EN-TARGET(WS-B)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-B)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 3 - 12
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z0 TO PL-Z(WS-PLAYER)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-C
     MOVE "acceptance 44-6§2.5 a listener angry at a player 12 blocks away takes the hoglin 1 block away" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.5 and the player is no longer its target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-B)
     MOVE 0 TO EN-FOE(WS-B) EN-FOE-ID(WS-B)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 3
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-C
     MOVE "acceptance 44-6§2.5 a player next to the listener is kept against a mob 1 block away" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.4 step 3 against a player target: attacker at 10 vs the player at 6 keeps the target, at 7 retargets.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 10
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 6
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.4 attacker at 10 vs the player target at 6: kept" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-D) = WS-X0 - 7
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.4 attacker at 7: the zoglin is the foe" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§2.4 and the player target is gone" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 1 of maybeRetaliate: a piglin avoiding (a zombified creature, no avoided kind recorded) does not retaliate.
     MOVE 0 TO EN-FOE(WS-A) EN-FOE-ID(WS-A) EN-TARGET(WS-A) EN-TARGET-ID(WS-A)
     MOVE WS-X0 TO WS-X
     MOVE 50 TO WS-FLAG
     CALL "PGB-AVOID-SET" USING WS-A WS-ONE WS-X WS-Z0 WS-FLAG
     CALL "PGAI-HURT-BY-MOB" USING WS-A WS-D
     MOVE "acceptance 44-6§2.4 step 1 the AVOID activity is active: no retaliation" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.2 step 1 on a fight: near a zombified piglin a piglin's foe is dropped (the sensor tick).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "zombified_piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 - 5
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     MOVE WS-C TO EN-FOE(WS-A)
     MOVE EN-ID(WS-C) TO EN-FOE-ID(WS-A)
     COMPUTE CW-TIME = 20000 - FUNCTION MOD(EN-ID(WS-A), 20)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.2 step 1 a zombified piglin within 6 blocks ends the fight" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-2M.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM T-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM T-SPAWN.

 COPY CORETEST.
 COPY MOBSPTEST.
