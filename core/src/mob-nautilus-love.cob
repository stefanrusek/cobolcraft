*> Love mode and babies of the nautilus (wrap I2 round 6, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 10.1, 10.2 and 10.5 with 18 sections 4.6 and 8.1).
*> The food (M188-FOOD, nautilus_food), the breeders list (M188-BREEDS), the offspring with the first parent's owner and tame flag (MOB-BREED-BABY) and the baby flag of metadata 16
*> (MOB-DATA-VALUES, from EN-MOBAGE) are in mob-18-8.cob; the zombie nautilus has no love and is never a baby (10.1, 10.8).
*>   NAUTILUS-LIFE USING row                       AgeableMob.aiStep and Animal.aiStep of a nautilus (M188-TICK): the baby's age counts up and the grown one sends the baby flag false, a cooldown counts
*>                                                 down, love counts down and ends while the age is not 0, the forced-age timer
*>   NAUTILUS-LOVE USING row, table row, walking out   AnimalMakeLove(NAUTILUS, 0.4, 2) (IDLE priority 1): see below
*>   NAUTILUS-LOVE-WALK USING row, partner row     BehaviorUtils.lockGazeAndWalkToEachOther: the swim of AQUA-CHASE toward the partner at speed 0.4
*> AnimalMakeLove state: EN-LOVE-PARTNER is the BREED_TARGET memory (both nautilus of a pairing hold each other), WC-NAU-LOVE-LEAD marks the one whose behaviour runs (the starter), EN-LOVE-TIME the
*> ticks it has run (it lasts 110), WC-NAU-LOVE-DELAY the ticks left of its delay 60 + nextInt(50). It starts when the nautilus is in love, not panicking and without a BREED_TARGET, and the closest
*> partner (MOB-PARTNER: in love, of the same species, within 8 blocks) has no BREED_TARGET either; it ends (both memories erased) when the partner is gone, no longer in love or panicking, or 110 ticks have
*> run. Each tick both walk to each other at speed 0.4; the starter calls spawnChildFromBreeding (MOB-BREED) once the partner is within 3 blocks and the delay has run out. The doc words the delay
*> "after breeding" (18 section 4.6); it is read as the delay before spawnChildFromBreeding because the behaviour lasts 110 ticks and the delay is at most 109.
*> Gaps (recorded on T24090): the partner sensor range is MOB-PARTNER's 8 blocks, not the follow range, and has no line of sight test; FollowTemptation does not run while a pairing walks (one move per tick).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-LIFE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-GROWN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "M188-TICK" USING EN-MOBAGE(L-ROW) EN-LOVE(L-ROW) EN-LOCKED(L-ROW) EN-FORCED(L-ROW) WS-GROWN
     IF WS-GROWN = 1
         MOVE 0 TO EN-VARIANT(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-LIFE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-LOVE-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG VALUE 0.4.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PARTNER              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PARTNER.
     MOVE EN-X(L-PARTNER) TO WS-X
     MOVE EN-Y(L-PARTNER) TO WS-Y
     MOVE EN-Z(L-PARTNER) TO WS-Z
     CALL "AQUA-CHASE" USING L-ROW WS-X WS-Y WS-Z WS-SPEED
     GOBACK.
 END PROGRAM NAUTILUS-LOVE-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-LOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-OTHER               PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LOVE-A              BINARY-LONG.
 01 WS-LOVE-B              BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 34.
 01 WS-BOUND               BINARY-LONG VALUE 50.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-WALKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-WALKING.
     MOVE 0 TO L-WALKING
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE EN-LOVE-PARTNER(L-ROW) TO WS-P
     IF WS-P = 0
*>       Start: in love, not panicking, and the closest partner has no BREED_TARGET.
         IF EN-LOVE(L-ROW) > 0 AND EN-FLEE(L-ROW) = 0
             CALL "MOB-PARTNER" USING L-ROW WS-Q
             IF WS-Q > 0 AND EN-LOVE-PARTNER(WS-Q) = 0
                 CALL "WC-ROW-OPEN" USING WS-Q
                 MOVE WS-Q TO EN-LOVE-PARTNER(L-ROW)
                 MOVE L-ROW TO EN-LOVE-PARTNER(WS-Q)
                 MOVE 1 TO WC-NAU-LOVE-LEAD(L-ROW)
                 MOVE 0 TO WC-NAU-LOVE-LEAD(WS-Q)
                 MOVE 0 TO EN-LOVE-TIME(L-ROW)
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
                 COMPUTE WC-NAU-LOVE-DELAY(L-ROW) = 60 + WS-DRAW
                 CALL "NAUTILUS-LOVE-WALK" USING L-ROW WS-Q
                 MOVE 1 TO L-WALKING
             END-IF
         END-IF
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING WS-P
     IF WC-NAU-LOVE-LEAD(L-ROW) = 0
*>       The partner of a pairing only walks to the starter while the starter's behaviour runs.
         IF EN-USED(WS-P) = 1 AND WC-NAU-LOVE-LEAD(WS-P) = 1 AND EN-LOVE-PARTNER(WS-P) = L-ROW
             CALL "NAUTILUS-LOVE-WALK" USING L-ROW WS-P
             MOVE 1 TO L-WALKING
         ELSE
             MOVE 0 TO EN-LOVE-PARTNER(L-ROW)
         END-IF
         GOBACK
     END-IF
*>   canStillUse: both alive, can mate (both in love, same species), neither panicking, the partner still points at this one, and fewer than 110 ticks run.
     MOVE 0 TO WS-OK
     IF EN-USED(WS-P) = 1 AND EN-HEALTH(WS-P) > 0 AND EN-DIM(WS-P) = EN-DIM(L-ROW) AND EN-FLEE(L-ROW) = 0 AND EN-FLEE(WS-P) = 0
             AND EN-LOVE-PARTNER(WS-P) = L-ROW AND EN-LOVE-TIME(L-ROW) < 110
         CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
         CALL "MOB-SPECIES-KEY" USING WS-P WS-OTHER
         MOVE EN-LOVE(L-ROW) TO WS-LOVE-A
         MOVE EN-LOVE(WS-P) TO WS-LOVE-B
         CALL "M188-CAN-MATE" USING WS-KEY WS-OTHER WS-LOVE-A WS-LOVE-B WS-OK
     END-IF
     IF WS-OK = 0
*>       stop: BREED_TARGET, walk and look targets erased (here on both nautilus of the pairing).
         IF EN-USED(WS-P) = 1 AND EN-LOVE-PARTNER(WS-P) = L-ROW
             MOVE 0 TO EN-LOVE-PARTNER(WS-P)
         END-IF
         MOVE 0 TO EN-LOVE-PARTNER(L-ROW) EN-LOVE-TIME(L-ROW) WC-NAU-LOVE-LEAD(L-ROW) WC-NAU-LOVE-DELAY(L-ROW)
         GOBACK
     END-IF
     ADD 1 TO EN-LOVE-TIME(L-ROW)
     IF WC-NAU-LOVE-DELAY(L-ROW) > 0
         SUBTRACT 1 FROM WC-NAU-LOVE-DELAY(L-ROW)
     END-IF
     CALL "NAUTILUS-LOVE-WALK" USING L-ROW WS-P
     MOVE 1 TO L-WALKING
     COMPUTE WS-DX = EN-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(WS-P) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
*>   closerThan(partner, 3.0) and the delay run out: spawnChildFromBreeding (MOB-BREED ends both pairings, love and the lead flag).
     IF WS-D2 < 9 AND WC-NAU-LOVE-DELAY(L-ROW) = 0
         MOVE 0 TO WC-NAU-LOVE-LEAD(L-ROW)
         CALL "MOB-BREED" USING L-ROW WS-P
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-LOVE.
