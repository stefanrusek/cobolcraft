*> Hoglin and zoglin brains (docs/protocol/44-residual-mob-questions-6-nether.md sections 4.3, 5.1 to 5.3, 6.1 to 6.3, V9; lane 002-lane-p49l): the melee intervals, PACIFIED near a
*> repellent, the walk away from a visible adult piglin (0.4) and the retreat (1.3), wantsToStopFleeing, wasHurtBy with retaliation and broadcastAttackTarget, onHitTarget and the
*> zoglin's retaliation. The memories are re-derived as observable state (EN-FOE, PG-AVOID, PG-PACIFIED).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
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
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-M                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-K24                 PIC X(24).
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-AVOIDING            BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TENTH               BINARY-LONG.
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
*>   Section 6.1: MeleeAttack(40) for an adult hoglin or zoglin, 15 for a baby; a piglin keeps 20.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 1
     MOVE "villager" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     MOVE WS-B TO EN-FOE(WS-A)
     MOVE EN-ID(WS-B) TO EN-FOE-ID(WS-A)
     MOVE 0 TO EN-PET-CD(WS-A)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-A) WS-M
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.1 an adult hoglin hits again after 40 ticks" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-PET-CD(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10000 TO EN-MOBAGE(WS-A)
     MOVE 0 TO EN-PET-CD(WS-A)
     CALL "MOBVS-TICK" USING WS-A WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.1 a baby hoglin hits again after 15 ticks" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE EN-PET-CD(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-C
     MOVE 0 TO EN-PET-CD(WS-C)
     MOVE 0 TO EN-FOE(WS-C) EN-FOE-ID(WS-C)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-C) WS-M
     CALL "MOBVS-TICK" USING WS-C WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.3 an adult zoglin hits again after 40 ticks" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-PET-CD(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-D
     COMPUTE WS-X = WS-X0 + 1
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-E
     MOVE WS-E TO EN-FOE(WS-D)
     MOVE EN-ID(WS-E) TO EN-FOE-ID(WS-D)
     MOVE 0 TO EN-PET-CD(WS-D)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-D) WS-M
     CALL "MOBVS-TICK" USING WS-D WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§2.1 a piglin's MELEE_ATTACK_COOLDOWN stays 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-PET-CD(WS-D) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 4.3, 6.2 and V9: a hoglin near a warped fungus (sensor tick) is PACIFIED for 200 ticks, loses its target, and a pacified hoglin takes none.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE "minecraft:warped_fungus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE CW-TIME = 20000 - FUNCTION MOD(EN-ID(WS-A), 20)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     CALL "PGB-SLOT" USING EN-ID(WS-A) WS-NO WS-SLOT
     MOVE "acceptance 44-6§V9 a hoglin near warped fungus is pacified for 200 ticks" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE PG-PACIFIED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 BecomePassiveIfMemoryPresent erases the attack target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO CW-TIME
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.2 a pacified hoglin has no player target (the finder is empty)" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 PACIFIED counts down" TO TL-CASE
     MOVE 199 TO TL-EXPECTED-N
     MOVE PG-PACIFIED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PG-PACIFIED(WS-SLOT)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.2 PACIFIED expires" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE PG-PACIFIED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 and the player is a target again" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO PG-PACIFIED(WS-SLOT)
     MOVE "hoglin" TO WS-K24
     COMPUTE WS-X = WS-X0 - 5
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-B
     MOVE "acceptance 44-6§6.2 wasHurtBy erases PACIFIED" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE PG-PACIFIED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO PG-PACIFIED(WS-SLOT)
     CALL "NETHER-HURT" USING WS-A WS-PLAYER
     MOVE "acceptance US15 44-6§6.2 a hit by a player erases PACIFIED too" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PG-PACIFIED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
*>   Section 6.2 IDLE: an adult hoglin walks away from a visible adult piglin within 8 blocks at speed 0.4, a baby does not.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE CW-TIME = 20000 - FUNCTION MOD(EN-ID(WS-A), 20)
     MOVE 0 TO EN-TARGET(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.2 an adult hoglin walks away from the piglin" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-N ROUNDED = WS-HX * 10000
     MOVE "acceptance 44-6§6.2 at 0.4 of its walk speed (0.198), away from it" TO TL-CASE
     MOVE -792 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10000 TO EN-MOBAGE(WS-A)
     CALL "PGB-FORGET" USING EN-ID(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.2 a baby hoglin does not keep away" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-A)
     COMPUTE EN-X(WS-B) = WS-X0 + 9
     CALL "PGB-FORGET" USING EN-ID(WS-A)
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§6.2 a piglin beyond 8 blocks: no walking away" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 6.2 AVOID: retreating at 1.3, and wantsToStopFleeing when the piglins no longer outnumber the hoglins.
     COMPUTE EN-X(WS-B) = WS-X0 + 3
     CALL "PGAI-HOGLIN-RETREAT" USING WS-A WS-B
     ADD 1 TO CW-TIME
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     COMPUTE WS-N ROUNDED = WS-HX * 10000
     MOVE "acceptance 44-6§6.2 AVOID walks away at 1.3 (0.2574)" TO TL-CASE
     MOVE -2574 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 19 TO CW-TIME
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     CALL "PGB-SLOT" USING EN-ID(WS-A) WS-NO WS-SLOT
     MOVE "acceptance 44-6§6.2 wantsToStopFleeing: one piglin does not outnumber, the retreat ends" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE PG-AVOID(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 4
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 5
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     CALL "PGAI-HOGLIN-RETREAT" USING WS-A WS-B
     ADD 20 TO CW-TIME
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE 0 TO WS-FLAG
     IF PG-AVOID(WS-SLOT) > 0
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§6.2 three piglins outnumber the hoglin: the retreat goes on" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 6.2 wasHurtBy: a hit by a hoglin is ignored, a baby retreats, an adult retaliates and the visible adult hoglins that are not pacified follow.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 3
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 - 4
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-F
     COMPUTE WS-X = WS-X0 + 4
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE WS-X = WS-X0 + 2
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-D
     MOVE "acceptance 44-6§6.2 step 2 an attacker hoglin is ignored" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-SLOT" USING EN-ID(WS-F) WS-ONE WS-SLOT
     MOVE 60 TO PG-PACIFIED(WS-SLOT)
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 step 5 an adult retaliates: the piglin is the attack target" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 broadcastAttackTarget: a visible adult hoglin takes it" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 ...but not a pacified one" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-F) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 3: an attacker much further than the current target does not retarget it.
     COMPUTE EN-X(WS-C) = WS-X0 + 11
     MOVE WS-D TO EN-FOE(WS-A)
     MOVE EN-ID(WS-D) TO EN-FOE-ID(WS-A)
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 step 3 attacker at 11 vs target at 2: the target stays" TO TL-CASE
     MOVE WS-D TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 1: while avoiding, a hit by a piglin is ignored.
     MOVE 0 TO EN-FOE(WS-A) EN-FOE-ID(WS-A)
     COMPUTE EN-X(WS-C) = WS-X0 + 4
     CALL "PGAI-HOGLIN-RETREAT" USING WS-A WS-C
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 step 1 avoiding: a piglin's hit does not retarget" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby retreats instead.
     MOVE -10000 TO EN-MOBAGE(WS-B)
     MOVE 0 TO EN-FOE(WS-B) EN-FOE-ID(WS-B)
     CALL "PGAI-HOGLIN-HURT" USING WS-B WS-C
     CALL "PGB-AVOIDING" USING WS-B WS-AVOIDING
     MOVE "acceptance 44-6§6.2 a baby hoglin retreats from its attacker" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 and has no attack target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   onHitTarget: piglins that outnumber the hoglin make it (and the visible adult hoglins) retreat; otherwise the other hoglins take the target; a baby does nothing.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 3
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 1
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     CALL "PGAI-HOGLIN-HIT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 onHitTarget with piglin 1 vs hoglin 1 + 1: the other hoglin takes the piglin" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§6.2 onHitTarget: the hitter does not retreat" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOE(WS-B) EN-FOE-ID(WS-B)
     COMPUTE WS-X = WS-X0 + 2
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-D
     COMPUTE WS-X = WS-X0 + 3
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-E
     CALL "PGAI-HOGLIN-HIT" USING WS-A WS-C
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§6.2 onHitTarget with piglins 3 > hoglin 1 + 1: the hoglin retreats" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOIDING" USING WS-B WS-AVOIDING
     MOVE "acceptance 44-6§6.2 broadcastRetreat: the other hoglin retreats" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 and takes no target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-FOE(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10000 TO EN-MOBAGE(WS-A)
     CALL "PGB-FORGET" USING EN-ID(WS-A)
     CALL "PGB-FORGET" USING EN-ID(WS-B)
     CALL "PGAI-HOGLIN-HIT" USING WS-A WS-C
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance 44-6§6.2 a baby hoglin's hit has no effect" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 6.3: a zoglin hit by a piglin takes it as its attack target (it can attack it and it is not much further).
     CALL "T-CLEAR"
     MOVE "zoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 4
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.3 a zoglin retaliates against its attacker" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 5.3 step 2: SetWalkTargetAwayFrom only acts within its distance: 12 for a piglin's AVOID, 15 for a hoglin's, 8 for a repellent or a piglin kept away from.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-B
     COMPUTE CW-TIME = 20001 - FUNCTION MOD(EN-ID(WS-A), 20)
     COMPUTE WS-N = FUNCTION MOD(CW-TIME + EN-ID(WS-B), 20)
     IF WS-N = 0
         ADD 1 TO CW-TIME
     END-IF
     MOVE 100 TO WS-TENTH
     COMPUTE WS-X = WS-X0 + 11
     CALL "PGB-AVOID-SET" USING WS-A WS-ONE WS-X WS-Z0 WS-TENTH
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.3 a piglin 11 blocks from its AVOID point (12) walks away" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 13
     CALL "PGB-AVOID-SET" USING WS-A WS-ONE WS-X WS-Z0 WS-TENTH
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.3 a piglin 13 blocks from it is out of the distance: it does not" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 14
     CALL "PGB-AVOID-SET" USING WS-B WS-ONE WS-X WS-Z0 WS-TENTH
     CALL "PGB-STEP" USING WS-B WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.3 a hoglin 14 blocks from its AVOID point (15) walks away" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 16
     CALL "PGB-AVOID-SET" USING WS-B WS-ONE WS-X WS-Z0 WS-TENTH
     CALL "PGB-STEP" USING WS-B WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.3 a hoglin 16 blocks from it does not" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 9
     CALL "PGB-AVOID-SET" USING WS-B WS-FOUR WS-X WS-Z0 WS-TENTH
     CALL "PGB-STEP" USING WS-B WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.3 kept away from a piglin at 9 blocks (8): no" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 5.7 BabyFollowAdult(5..16, 0.6): a baby hoglin walks toward a visible adult hoglin that is not closer than 5, at 0.6 of its speed.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE -10000 TO EN-MOBAGE(WS-A)
     COMPUTE WS-X = WS-X0 + 8
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.7 a baby hoglin follows an adult 8 blocks away" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-N ROUNDED = WS-HX * 10000
     MOVE "acceptance 44-6§5.7 at 0.6 of its speed (0.1188), toward the adult" TO TL-CASE
     MOVE 1188 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-B) = WS-X0 + 4
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.7 closer than 5 blocks: it stays" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10000 TO EN-MOBAGE(WS-B)
     COMPUTE EN-X(WS-B) = WS-X0 + 8
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance 44-6§5.7 another baby is no adult to follow" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hoglin angry at a player: an attacker much further than that target does not retarget it, one at 7 against 6 does (step 3 and 5).
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 - 10
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 6
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z0 TO PL-Z(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 step 3 piglin at 10 vs the player target at 6: kept" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-C) = WS-X0 - 7
     CALL "PGAI-HOGLIN-HURT" USING WS-A WS-C
     MOVE "acceptance 44-6§6.2 step 5 piglin at 7: it is the attack target" TO TL-CASE
     MOVE WS-C TO TL-EXPECTED-N
     MOVE EN-FOE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§6.2 and the player is no longer the target" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An avoid point at the hoglin's own position: it walks off along +X.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE CW-TIME = 20001 - FUNCTION MOD(EN-ID(WS-A), 20)
     MOVE 100 TO WS-TENTH
     MOVE EN-X(WS-A) TO WS-X
     MOVE EN-Z(WS-A) TO WS-Z
     CALL "PGB-AVOID-SET" USING WS-A WS-ONE WS-X WS-Z WS-TENTH
     CALL "PGB-STEP" USING WS-A WS-HX WS-HZ WS-WALK
     COMPUTE WS-N ROUNDED = WS-HX * 10000
     MOVE "acceptance 44-6§5.3 at the point to avoid the direction is +X (0.2574)" TO TL-CASE
     MOVE 2574 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-6.

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
