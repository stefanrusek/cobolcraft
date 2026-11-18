*> The piglin and hoglin hostility engine over mobs (docs/protocol/44-residual-mob-questions-6-nether.md sections 1, 2.2 to 2.8, 4.1, 4.3, 6.2, 6.3; lane 002-lane-p49l). The brain model of
*> the document (memories with an expiry, sensors every 20 ticks) is re-derived as observable state, not built as a store: the memories are EN-FOE (the mob that is ANGRY_AT / the ATTACK_TARGET
*> of a piglin or hoglin), PG-AVOID (AVOID_TARGET, PGBRAIN.cpy), PG-PACIFIED, PH-TIMER (HUNTED_RECENTLY, HUNT.cpy) and the sensors are computed from the entities when they are asked
*> (PGAI-SENSE: the visible adult lists and counts of 4.1 and 4.3). Players stay targets through EN-TARGET (NETHER-AGGRO); these programs add the mob attackers and targets.
*> Gaps: UNIVERSAL_ANGER for mob attackers (only players write it), StopAttackingIfTargetInvalid's 200 ticks unable to reach the walk target (core gives no path failure signal), the Wither as
*> a nemesis (not a standard mob), a hoglin's CannotBeHunted flag (nothing sets it).
*>   PGAI-KIND USING row, kind out                  1 piglin, 2 piglin brute, 3 hoglin, 4 zoglin, 0 any other mob
*>   PGAI-MUCH-FURTHER USING has target, d2 other, d2 current, flag out       isOtherTargetMuchFurtherAwayThanCurrentAttackTarget(4.0): other > current + 16 (squared distances)
*>   PGAI-OUTNUMBER USING kind, piglins, hoglins, flag out                    kind 1: hoglinsOutnumberPiglins (hoglins > piglins + 1); 2: piglinsOutnumberHoglins of an adult hoglin (piglins > hoglins + 1)
*>   PGAI-SENSE USING row, kind, piglins out, hoglins out, hoglin row out, piglin row out    kind 1 the PiglinSpecificSensor (visible adult piglins and brutes, adult hoglins, the nearest adult hoglin);
*>                                                                             kind 2 the HoglinSpecificSensor (adult piglins, brutes excluded; the nearest adult piglin). Within 16 blocks and in line of sight; never the mob itself
*>   PGAI-GAP USING piglin row                      HUNTED_RECENTLY: the hunting gap of 30 to 120 s starts
*>   PGAI-RETREAT USING piglin row, attacker row    setAvoidTargetAndDontHuntForAWhile: erase the anger and target, AVOID_TARGET 100 to 400 ticks, no hunting
*>   PGAI-ANGER-FOE USING listener row, target row  setAngerTargetIfCloserThanCurrent
*>   PGAI-BROADCAST USING source row, target row    broadcastAngerTarget over the adult piglins and brutes within 16 blocks
*>   PGAI-HURT-BY-MOB USING piglin or brute row, attacker row     PiglinAi.wasHurtBy / PiglinBruteAi.wasHurtBy / maybeRetaliate for a mob attacker
*>   PGAI-HOGLIN-HURT USING hoglin or zoglin row, attacker row    HoglinAi.wasHurtBy / Zoglin.hurtServer for a mob attacker
*>   PGAI-HOGLIN-HIT USING hoglin row, target row   HoglinAi.onHitTarget after a melee hit

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND.
     MOVE 0 TO L-KIND
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         EVALUATE SM-KEY(WS-M)
             WHEN "piglin"
                 MOVE 1 TO L-KIND
             WHEN "piglin_brute"
                 MOVE 2 TO L-KIND
             WHEN "hoglin"
                 MOVE 3 TO L-KIND
             WHEN "zoglin"
                 MOVE 4 TO L-KIND
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM PGAI-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-MUCH-FURTHER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-OTHER                FLOAT-LONG.
 01 L-CURRENT              FLOAT-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-OTHER L-CURRENT L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-HAS = 1 AND L-OTHER > L-CURRENT + 16
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM PGAI-MUCH-FURTHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-OUTNUMBER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PIGLINS              BINARY-LONG.
 01 L-HOGLINS              BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PIGLINS L-HOGLINS L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-KIND = 1 AND L-HOGLINS > L-PIGLINS + 1
         MOVE 1 TO L-FLAG
     END-IF
     IF L-KIND = 2 AND L-PIGLINS > L-HOGLINS + 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM PGAI-OUTNUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-SENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-BEST-H              FLOAT-LONG.
 01 WS-BEST-P              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-PIGLINS              BINARY-LONG.
 01 L-HOGLINS              BINARY-LONG.
 01 L-HOGLIN               BINARY-LONG.
 01 L-PIGLIN               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-PIGLINS L-HOGLINS L-HOGLIN L-PIGLIN.
     MOVE 0 TO L-PIGLINS L-HOGLINS L-HOGLIN L-PIGLIN
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.5
     MOVE EN-Z(L-ROW) TO WS-AZ
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0
                 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
             COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
             COMPUTE WS-DY = FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
             CALL "PGAI-KIND" USING WS-E WS-K
             IF WS-DX <= 16 AND WS-DY <= 16 AND WS-DZ <= 16 AND (WS-K = 1 OR WS-K = 2 OR WS-K = 3)
                 COMPUTE WS-BY = EN-Y(WS-E) + 1
                 CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ EN-X(WS-E) WS-BY EN-Z(WS-E) WS-SEES
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-SEES = 1 AND WS-K = 3
                     ADD 1 TO L-HOGLINS
                     IF L-HOGLIN = 0 OR WS-D2 < WS-BEST-H
                         MOVE WS-E TO L-HOGLIN
                         MOVE WS-D2 TO WS-BEST-H
                     END-IF
                 END-IF
                 IF WS-SEES = 1 AND (WS-K = 1 OR (WS-K = 2 AND L-KIND = 1))
                     ADD 1 TO L-PIGLINS
                     IF L-PIGLIN = 0 OR WS-D2 < WS-BEST-P
                         MOVE WS-E TO L-PIGLIN
                         MOVE WS-D2 TO WS-BEST-P
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGAI-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-GAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HUNT.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PH-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX OR WS-SLOT > 0
             IF PH-ID(WS-I) = 0
                 MOVE EN-ID(L-ROW) TO PH-ID(WS-I)
                 MOVE WS-I TO WS-SLOT
             END-IF
         END-PERFORM
     END-IF
     IF WS-SLOT > 0
         CALL "PH-GAP" USING PH-TIMER(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PGAI-GAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-RETREAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SALT                BINARY-LONG VALUE 111.
 01 WS-BOUND               BINARY-LONG VALUE 301.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     COMPUTE WS-TICKS = 100 + WS-DRAW
     MOVE EN-X(L-ATTACKER) TO WS-X
     MOVE EN-Z(L-ATTACKER) TO WS-Z
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW) EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) EN-ANGER(L-ROW)
     CALL "PGB-AVOID-SET" USING L-ROW WS-KIND WS-X WS-Z WS-TICKS
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT > 0
         MOVE EN-TYPE(L-ATTACKER) TO PG-AVTYPE(WS-SLOT)
     END-IF
     CALL "PGAI-KIND" USING L-ROW WS-PK
     IF WS-PK = 1
         CALL "PGAI-GAP" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PGAI-RETREAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-ANGER-FOE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HAS                 BINARY-LONG.
 01 WS-CUR                 FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET.
     MOVE 0 TO WS-HAS
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) = 1 AND EN-ID(WS-F) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-F) > 0
             MOVE 1 TO WS-HAS
             COMPUTE WS-CUR = (EN-X(WS-F) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-F) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-F) - EN-Z(L-ROW)) ** 2
         END-IF
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-HAS = 0 AND WS-P > 0
         MOVE 1 TO WS-HAS
         COMPUTE WS-CUR = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     COMPUTE WS-NEW = (EN-X(L-TARGET) - EN-X(L-ROW)) ** 2 + (EN-Y(L-TARGET) - EN-Y(L-ROW)) ** 2 + (EN-Z(L-TARGET) - EN-Z(L-ROW)) ** 2
*>   getNearestTarget: the new target replaces the current one only when it is nearer.
     IF WS-HAS = 0 OR WS-NEW < WS-CUR
         MOVE L-TARGET TO EN-FOE(L-ROW)
         MOVE EN-ID(L-TARGET) TO EN-FOE-ID(L-ROW)
         MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM PGAI-ANGER-FOE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-BROADCAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TK                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-TARGET.
     CALL "PGAI-KIND" USING L-TARGET WS-TK
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-SOURCE AND WS-E NOT = L-TARGET AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0
                 AND EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = EN-DIM(L-SOURCE) AND EN-MOBAGE(WS-E) >= 0
             COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-SOURCE))
             COMPUTE WS-DY = FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-SOURCE))
             COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-SOURCE))
             CALL "PGAI-KIND" USING WS-E WS-K
             IF WS-DX <= 16 AND WS-DY <= 16 AND WS-DZ <= 16 AND (WS-K = 1 OR WS-K = 2)
*>               A hoglin is taken on only by a listener that can hunt (a Piglin, not a brute); it starts that listener's hunting gap too.
                 IF WS-TK = 3 AND WS-K = 1
                     CALL "PGAI-ANGER-FOE" USING WS-E L-TARGET
                     CALL "PGAI-GAP" USING WS-E
                 END-IF
                 IF WS-TK NOT = 3
                     CALL "PGAI-ANGER-FOE" USING WS-E L-TARGET
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGAI-BROADCAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HURT-BY-MOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-K                   BINARY-LONG.
 01 WS-AK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-BABY-KIND           BINARY-LONG VALUE 3.
 01 WS-BABY-TICKS          BINARY-LONG VALUE 100.
 01 WS-AVOIDING            BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-SENSE-KIND          BINARY-LONG VALUE 1.
 01 WS-HAS                 BINARY-LONG.
 01 WS-D-OTHER             FLOAT-LONG.
 01 WS-D-CUR               FLOAT-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-LK                  BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "PGAI-KIND" USING L-ROW WS-K
     CALL "PGAI-KIND" USING L-ATTACKER WS-AK
*>   Step 1 (and the brute's): a piglin attacker is ignored; a piglin ignores no brute attacker, a brute ignores both.
     IF WS-AK = 1 OR (WS-AK = 2 AND WS-K = 2)
         GOBACK
     END-IF
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-K = 1 AND WS-SLOT > 0
*>       Steps 2 and 3: the off-hand item is put away and the celebration ends; only a player sets ADMIRING_DISABLED (step 4).
         IF EN-ADMIRE(L-ROW) > 0
             MOVE 0 TO EN-ADMIRE(L-ROW)
             CALL "PGB-OFFHAND-STOP" USING L-ROW WS-KEPT
         END-IF
         CALL "PGB-CELEBRATE-STOP" USING L-ROW
         MOVE 0 TO PG-CELEB(WS-SLOT)
*>       Step 5: a hit by another kind of creature ends the current retreat.
         IF PG-AVOID(WS-SLOT) > 0 AND PG-AVOID-KIND(WS-SLOT) = 1 AND PG-AVTYPE(WS-SLOT) > 0 AND PG-AVTYPE(WS-SLOT) NOT = EN-TYPE(L-ATTACKER)
             MOVE 0 TO PG-AVOID(WS-SLOT)
         END-IF
*>       Step 6: a baby avoids its attacker for 100 ticks and the others are told.
         IF EN-MOBAGE(L-ROW) < 0
             MOVE EN-X(L-ATTACKER) TO WS-X
             MOVE EN-Z(L-ATTACKER) TO WS-Z
             CALL "PGB-AVOID-SET" USING L-ROW WS-BABY-KIND WS-X WS-Z WS-BABY-TICKS
             CALL "PGAI-BROADCAST" USING L-ROW L-ATTACKER
             GOBACK
         END-IF
*>       Step 7: hoglins that outnumber the piglins make it retreat, and the other visible piglins with it.
         IF WS-AK = 3
             CALL "PGAI-SENSE" USING L-ROW WS-SENSE-KIND WS-NP WS-NH WS-HUNT WS-NEAR
             CALL "PGAI-OUTNUMBER" USING WS-SENSE-KIND WS-NP WS-NH WS-FLAG
             IF WS-FLAG = 1
                 CALL "PGAI-RETREAT" USING L-ROW L-ATTACKER
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                     IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0
                             AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
                         CALL "PGAI-KIND" USING WS-E WS-LK
                         IF WS-LK = 1 AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 16
                             CALL "PGAI-RETREAT" USING WS-E L-ATTACKER
                         END-IF
                     END-IF
                 END-PERFORM
                 GOBACK
             END-IF
         END-IF
     END-IF
*>   maybeRetaliate (2.4): not while avoiding, not against an attacker much further than the current target.
     CALL "PGB-AVOIDING" USING L-ROW WS-AVOIDING
     IF WS-AVOIDING = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-HAS
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) = 1 AND EN-ID(WS-F) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-F) > 0
             MOVE 1 TO WS-HAS
             COMPUTE WS-D-CUR = (EN-X(WS-F) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-F) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-F) - EN-Z(L-ROW)) ** 2
         END-IF
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-HAS = 0 AND WS-P > 0
         MOVE 1 TO WS-HAS
         COMPUTE WS-D-CUR = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     COMPUTE WS-D-OTHER = (EN-X(L-ATTACKER) - EN-X(L-ROW)) ** 2 + (EN-Y(L-ATTACKER) - EN-Y(L-ROW)) ** 2 + (EN-Z(L-ATTACKER) - EN-Z(L-ROW)) ** 2
     CALL "PGAI-MUCH-FURTHER" USING WS-HAS WS-D-OTHER WS-D-CUR WS-FLAG
     IF WS-FLAG = 1
         GOBACK
     END-IF
*>   setAngerTarget (2.5): the attacker is the foe; attacking a hoglin starts the hunting gap of a piglin that can hunt; the others near are told.
     MOVE L-ATTACKER TO EN-FOE(L-ROW)
     MOVE EN-ID(L-ATTACKER) TO EN-FOE-ID(L-ROW)
     MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
     IF WS-AK = 3 AND WS-K = 1
         CALL "PGAI-GAP" USING L-ROW
     END-IF
     CALL "PGAI-BROADCAST" USING L-ROW L-ATTACKER
     GOBACK.
 END PROGRAM PGAI-HURT-BY-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HOGLIN-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-K                   BINARY-LONG.
 01 WS-AK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-SALT                BINARY-LONG VALUE 112.
 01 WS-BOUND               BINARY-LONG VALUE 301.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D-CUR               FLOAT-LONG.
 01 WS-D-OTHER             FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EK                  BINARY-LONG.
 01 WS-ESLOT               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "PGAI-KIND" USING L-ROW WS-K
     CALL "PGAI-KIND" USING L-ATTACKER WS-AK
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-K = 3 AND WS-SLOT > 0
*>       A hit erases PACIFIED (BREED_TARGET is not modelled).
         MOVE 0 TO PG-PACIFIED(WS-SLOT)
         IF EN-MOBAGE(L-ROW) < 0
*>           A baby retreats from its attacker for 100 to 400 ticks.
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             COMPUTE WS-TICKS = 100 + WS-DRAW
             MOVE EN-X(L-ATTACKER) TO WS-X
             MOVE EN-Z(L-ATTACKER) TO WS-Z
             MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW) EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
             CALL "PGB-AVOID-SET" USING L-ROW WS-KIND WS-X WS-Z WS-TICKS
             GOBACK
         END-IF
*>       maybeRetaliate: not while avoiding when the attacker is a piglin; never against a hoglin.
         IF PG-AVOID(WS-SLOT) > 0 AND WS-AK = 1
             GOBACK
         END-IF
         IF WS-AK = 3
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO WS-HAS
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) = 1 AND EN-ID(WS-F) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-F) > 0
             MOVE 1 TO WS-HAS
             COMPUTE WS-D-CUR = (EN-X(WS-F) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-F) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-F) - EN-Z(L-ROW)) ** 2
         END-IF
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-HAS = 0 AND WS-P > 0
         MOVE 1 TO WS-HAS
         COMPUTE WS-D-CUR = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     COMPUTE WS-D-OTHER = (EN-X(L-ATTACKER) - EN-X(L-ROW)) ** 2 + (EN-Y(L-ATTACKER) - EN-Y(L-ROW)) ** 2 + (EN-Z(L-ATTACKER) - EN-Z(L-ROW)) ** 2
     CALL "PGAI-MUCH-FURTHER" USING WS-HAS WS-D-OTHER WS-D-CUR WS-FLAG
     IF WS-FLAG = 1
         GOBACK
     END-IF
*>   setAttackTarget: the attacker is the target for 200 ticks.
     MOVE L-ATTACKER TO EN-FOE(L-ROW)
     MOVE EN-ID(L-ATTACKER) TO EN-FOE-ID(L-ROW)
     MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
     IF WS-K = 3
*>       broadcastAttackTarget: every visible adult hoglin that is not pacified takes it when it is nearer than its current one.
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND WS-E NOT = L-ATTACKER AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0
                     AND EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
                 CALL "PGAI-KIND" USING WS-E WS-EK
                 CALL "PGB-SLOT" USING EN-ID(WS-E) WS-NO WS-ESLOT
                 MOVE 0 TO WS-FLAG
                 IF WS-ESLOT > 0
                     IF PG-PACIFIED(WS-ESLOT) > 0
                         MOVE 1 TO WS-FLAG
                     END-IF
                 END-IF
                 IF WS-EK = 3 AND WS-FLAG = 0 AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 16
                     CALL "PGAI-ANGER-FOE" USING WS-E L-ATTACKER
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PGAI-HOGLIN-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HOGLIN-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-K                   BINARY-LONG.
 01 WS-TK                  BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-SENSE-KIND          BINARY-LONG VALUE 2.
 01 WS-OUT-KIND            BINARY-LONG VALUE 2.
 01 WS-FLAG                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET.
     CALL "PGAI-KIND" USING L-TARGET WS-TK
     IF EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     MOVE 0 TO WS-FLAG
     IF WS-TK = 1
         CALL "PGAI-SENSE" USING L-ROW WS-SENSE-KIND WS-NP WS-NH WS-HUNT WS-NEAR
         CALL "PGAI-OUTNUMBER" USING WS-OUT-KIND WS-NP WS-NH WS-FLAG
     END-IF
     IF WS-FLAG = 1
*>       The piglins outnumber the hoglins: it retreats from the piglin and every visible adult hoglin with it.
         CALL "PGAI-HOGLIN-RETREAT" USING L-ROW L-TARGET
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0
                     AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
                 CALL "PGAI-KIND" USING WS-E WS-EK
                 IF WS-EK = 3 AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 16
                     CALL "PGAI-HOGLIN-RETREAT" USING WS-E L-TARGET
                 END-IF
             END-IF
         END-PERFORM
     ELSE
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND WS-E NOT = L-TARGET AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0
                     AND EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
                 CALL "PGAI-KIND" USING WS-E WS-EK
                 IF WS-EK = 3 AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 16
                     CALL "PGAI-ANGER-FOE" USING WS-E L-TARGET
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PGAI-HOGLIN-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HOGLIN-RETREAT.
*> USING hoglin row, attacker row: setAvoidTarget: erase the target, AVOID_TARGET for 100 to 400 ticks (kind 1: a hoglin walks away at 1.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 113.
 01 WS-BOUND               BINARY-LONG VALUE 301.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     COMPUTE WS-TICKS = 100 + WS-DRAW
     MOVE EN-X(L-ATTACKER) TO WS-X
     MOVE EN-Z(L-ATTACKER) TO WS-Z
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW) EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
     CALL "PGB-AVOID-SET" USING L-ROW WS-KIND WS-X WS-Z WS-TICKS
     GOBACK.
 END PROGRAM PGAI-HOGLIN-RETREAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ATTACK-GAP.
*> USING tracker row, table row, ticks out: the ticks between two melee hits (MeleeAttack): 40 for an adult hoglin or zoglin and 15 for a baby (44-6 section 6.1 ATTACK_INTERVAL and
*> BABY_ATTACK_INTERVAL), else SM-ATTACK-TICKS (a piglin and a brute use 20, section 2.1 MELEE_ATTACK_COOLDOWN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-TICKS.
     MOVE SM-ATTACK-TICKS TO L-TICKS
     IF SM-KEY(L-M) = "hoglin" OR SM-KEY(L-M) = "zoglin"
         MOVE 40 TO L-TICKS
         IF EN-MOBAGE(L-ROW) < 0
             MOVE 15 TO L-TICKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ATTACK-GAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HOGLIN-SENSE.
*> USING hoglin row, PGBRAIN slot, repellent found (0/1): the HoglinSpecificSensor's effect on the IDLE and AVOID activities (44-6 sections 4.3 and 6.2), every 20 ticks. A retreating adult
*> stops when the piglins no longer outnumber the hoglins (wantsToStopFleeing); an idle adult with no target walks away from the nearest visible adult piglin closer than 8 blocks
*> (SetWalkTargetAwayFrom.entity, speed 0.4, override false: PG-AVOID-KIND 4 for the 20 ticks until the next scan), unless a repellent makes it walk away already.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-FLAG                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-FOUND.
     IF EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     CALL "PGAI-SENSE" USING L-ROW WS-KIND WS-NP WS-NH WS-HUNT WS-NEAR
     IF PG-AVOID(L-SLOT) > 0 AND PG-AVOID-KIND(L-SLOT) = 1
         CALL "PGAI-OUTNUMBER" USING WS-KIND WS-NP WS-NH WS-FLAG
         IF WS-FLAG = 0
             MOVE 0 TO PG-AVOID(L-SLOT)
         END-IF
         GOBACK
     END-IF
     IF WS-NEAR > 0 AND L-FOUND = 0 AND EN-TARGET(L-ROW) = 0 AND EN-FOE(L-ROW) = 0
         COMPUTE WS-D2 = (EN-X(WS-NEAR) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-NEAR) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-NEAR) - EN-Z(L-ROW)) ** 2
         IF WS-D2 < 64
             MOVE 20 TO PG-AVOID(L-SLOT)
             MOVE 4 TO PG-AVOID-KIND(L-SLOT)
             MOVE EN-X(WS-NEAR) TO PG-AX(L-SLOT)
             MOVE EN-Z(WS-NEAR) TO PG-AZ(L-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGAI-HOGLIN-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-HURT-BY-PLAYER.
*> USING piglin or brute row, attacker player row, handled out: the part of PiglinAi.wasHurtBy and maybeRetaliate (44-6 sections 2.3 steps 2, 3 and 5, 2.4 steps 3 and 4, 2.5) for a player
*> attacker that NETHER-HURT does not do: a hit ends the celebration and a retreat (the player is another kind of creature), is ignored against a target nearer by the 4.0 rule, and with
*> universal_anger takes the nearest attackable player (setAngerTargetToNearestTargetablePlayerIfFound) and tells every adult piglin and brute within 16 blocks (broadcastUniversalAnger:
*> each its own nearest player). handled 1 when nothing more is to be done; 0 leaves the plain anger at the attacker to the caller. UNIVERSAL_ANGER itself is not kept (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-K                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-HAS                 BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D-CUR               FLOAT-LONG.
 01 WS-D-OTHER             FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "universal_anger".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-E                   BINARY-LONG.
 01 WS-EK                  BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "PGAI-KIND" USING L-ROW WS-K
     IF WS-K NOT = 1 AND WS-K NOT = 2
         GOBACK
     END-IF
     IF WS-K = 1
         CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
         IF WS-SLOT > 0
             CALL "PGB-CELEBRATE-STOP" USING L-ROW
             MOVE 0 TO PG-CELEB(WS-SLOT)
             IF PG-AVOID(WS-SLOT) > 0 AND PG-AVOID-KIND(WS-SLOT) = 1
                 MOVE 0 TO PG-AVOID(WS-SLOT)
             END-IF
         END-IF
     END-IF
     MOVE 0 TO WS-HAS
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) = 1 AND EN-ID(WS-F) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-F) > 0
             MOVE 1 TO WS-HAS
             COMPUTE WS-D-CUR = (EN-X(WS-F) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-F) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-F) - EN-Z(L-ROW)) ** 2
         END-IF
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-HAS = 0 AND WS-P > 0
         MOVE 1 TO WS-HAS
         COMPUTE WS-D-CUR = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     COMPUTE WS-D-OTHER = (PL-X(L-ATTACKER) - EN-X(L-ROW)) ** 2 + (PL-Y(L-ATTACKER) - EN-Y(L-ROW)) ** 2 + (PL-Z(L-ATTACKER) - EN-Z(L-ROW)) ** 2
     CALL "PGAI-MUCH-FURTHER" USING WS-HAS WS-D-OTHER WS-D-CUR WS-FLAG
     IF WS-FLAG = 1 AND WS-P NOT = L-ATTACKER
         MOVE 1 TO L-HANDLED
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 1 AND PL-MODE(L-ATTACKER) NOT = 1 AND PL-MODE(L-ATTACKER) NOT = 3
         MOVE 1 TO L-HANDLED
         CALL "PGAI-NEAREST-PLAYER" USING L-ROW L-ATTACKER
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0
                     AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-E) >= 0
                     AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW)) <= 16
                     AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 16
                 CALL "PGAI-KIND" USING WS-E WS-EK
                 IF WS-EK = 1 OR WS-EK = 2
                     CALL "PGAI-NEAREST-PLAYER" USING WS-E L-ATTACKER
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PGAI-HURT-BY-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-NEAREST-PLAYER.
*> USING piglin row, fallback player row: setAngerTargetToNearestTargetablePlayerIfFound: the nearest survival or adventure player within 16 blocks, else the fallback becomes its target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FALLBACK             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FALLBACK.
     MOVE L-FALLBACK TO WS-TARGET
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2) AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-STATE(WS-P) = PS-ALIVE
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= 256 AND (WS-BEST = 0 OR WS-D2 < WS-BEST)
                 MOVE WS-D2 TO WS-BEST
                 MOVE WS-P TO WS-TARGET
             END-IF
         END-IF
     END-PERFORM
     CALL "NETHER-ANGER-TICKS" USING L-ROW WS-TICKS
     MOVE WS-TICKS TO EN-ANGER(L-ROW)
     MOVE WS-TARGET TO EN-TARGET(L-ROW)
     MOVE PL-ENTITY-ID(WS-TARGET) TO EN-TARGET-ID(L-ROW)
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
     GOBACK.
 END PROGRAM PGAI-NEAREST-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-UNPACIFY.
*> USING hoglin row: a hit erases PACIFIED (HoglinAi.wasHurtBy, 44-6 section 6.2); a hit by a player reaches it from NETHER-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PGAI-KIND" USING L-ROW WS-K
     IF WS-K = 3
         CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
         IF WS-SLOT > 0
             MOVE 0 TO PG-PACIFIED(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGAI-UNPACIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGAI-BABY-FOLLOW.
*> USING baby hoglin row, hx out, hz out, walk out: BabyFollowAdult(5 to 16, 0.6) (44-6 section 5.7 and 6.2): the nearest visible adult hoglin that is closer than 17 blocks and
*> not closer than 5 is walked to at 0.6 of the hoglin's speed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-ADULT               BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     CALL "PGAI-SENSE" USING L-ROW WS-KIND WS-NP WS-NH WS-ADULT WS-NEAR
     IF WS-ADULT > 0
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         COMPUTE WS-DX = EN-X(WS-ADULT) - EN-X(L-ROW)
         COMPUTE WS-DZ = EN-Z(WS-ADULT) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + (EN-Y(WS-ADULT) - EN-Y(L-ROW)) ** 2 + WS-DZ * WS-DZ
         IF WS-D2 >= 25 AND WS-D2 < 289
             COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
             IF WS-H > 0.01
                 COMPUTE L-HX = WS-DX / WS-H * SM-WALK-MILLI(WS-M) / 1000 * 0.6
                 COMPUTE L-HZ = WS-DZ / WS-H * SM-WALK-MILLI(WS-M) / 1000 * 0.6
                 MOVE 1 TO L-WALK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGAI-BABY-FOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOGLIN-WALK-VALUE.
*> USING hoglin row, x, y, z (BINARY-LONG block position), value out (BINARY-LONG): Hoglin.getWalkTargetValue (44-6 section 6.2): -1 within 8 blocks of the nearest repellent block
*> (the sensor's NEAREST_REPELLENT of the hoglin, PGB-REPEL kind 2), 10 when the block below is crimson nylium, else 0. Like MONSTER-WALK-VALUE it is the rule a pathing choice reads.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-VALUE.
     MOVE 0 TO L-VALUE
     CALL "PGB-REPEL" USING L-ROW WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
     IF WS-FOUND = 1
         COMPUTE WS-D2 = (L-X - WS-RX) ** 2 + (L-Y - WS-RY) ** 2 + (L-Z - WS-RZ) ** 2
         IF WS-D2 < 64
             MOVE -1 TO L-VALUE
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-BELOW = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) L-X WS-BELOW L-Z WS-STATE
     IF WS-STATE NOT = 0
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
         IF WS-KEY = "minecraft:crimson_nylium" OR "crimson_nylium"
             MOVE 10 TO L-VALUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HOGLIN-WALK-VALUE.
