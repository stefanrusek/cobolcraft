*> The piglin and hoglin brain remainder (docs/protocol/44-residual-mob-questions-6-nether.md sections 2.1, 2.3, 2.5, 2.10, 3.3, 3.4, 4.1, 4.3, 5.3; 21 section 5.5.1; lane 002-lane-mobsb7).
*> State: core/copy/PGBRAIN.cpy. Built here: the repellent sensor (PGB-REPEL: the nearest block of tag piglin_repellents, soul fire, soul torch, soul lantern, soul wall torch and a lit soul
*> campfire, or hoglin_repellents, warped fungus, potted warped fungus, nether portal and respawn anchor, within the Manhattan box of 8 x 4) with the retreat from it (SetWalkTargetAwayFrom,
*> speed 1.0, refreshed by the sensor every 20 ticks, only while the mob has no target), the avoidance of a zombified piglin or zoglin within 6 blocks (an adult or baby piglin: no target,
*> 100 to 140 ticks walking away), the celebration after a kill (300 ticks at the place, dancing with probability 1/10, metadata 19), the walk to a loved item within 9 blocks
*> (GoToWantedItem, given up for 200 ticks after 200 ticks of trying) and the baby that avoids its attacker for 100 ticks.
*> Open: the CrossbowAttack state machine and BackUpIfTooClose (not read in the documents: Open question 5), the nemesis (wither skeletons and Withers as attack targets of piglins and brutes:
*> mobs do not target mobs here), line of sight of the sensors for the repellent (blocks are not occluded), the baby piglin's nemesis avoidance, the item pick-up of nuggets, food and
*> equipment, riding hoglins as a baby, the speed 0.6 of idling and dancing is applied to the dance only, the sound of the activities.
*>   PGB-SLOT USING entity id, create (0/1), slot out
*>   PGB-FORGET USING entity id
*>   PGB-AVOID-SET USING row, kind, x, z (FLOAT-LONG), ticks
*>   PGB-AVOID-LEFT USING row, ticks out;  PGB-CELEBRATE-LEFT USING row, ticks out;  PGB-DANCE-OF USING entity id, state out
*>   PGB-REPEL USING row, kind (1 piglin, 2 hoglin), found out, x, y, z out
*>   PGB-ZOMB USING row, zombified row out, squared distance out
*>   PGB-CELEBRATE USING piglin row, target row, draw (0 to 9: 0 dances);  PGB-CELEBRATE-STOP USING row
*>   PGB-AVOIDING USING row, avoiding out          (a zombified creature is being avoided: NETHER-AGGRO gives no target)
*>   PGB-STEP USING row, hx out, hz out, walk out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PGBRAIN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PG-MAX OR L-SLOT > 0
         IF PG-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PG-MAX OR L-SLOT > 0
             IF PG-ID(WS-I) = 0
                 INITIALIZE PG-ENTRY(WS-I)
                 MOVE L-ID TO PG-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PGB-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-FORGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "PGB-SLOT" USING L-ID WS-NO WS-SLOT
     IF WS-SLOT > 0
         INITIALIZE PG-ENTRY(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PGB-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-AVOID-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-X L-Z L-TICKS.
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT > 0
         MOVE L-TICKS TO PG-AVOID(WS-SLOT)
         MOVE L-KIND TO PG-AVOID-KIND(WS-SLOT)
         MOVE L-X TO PG-AX(WS-SLOT)
         MOVE L-Z TO PG-AZ(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PGB-AVOID-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-AVOID-LEFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     MOVE 0 TO L-TICKS
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE PG-AVOID(WS-SLOT) TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM PGB-AVOID-LEFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-CELEBRATE-LEFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     MOVE 0 TO L-TICKS
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE PG-CELEB(WS-SLOT) TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM PGB-CELEBRATE-LEFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-DANCE-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-STATE.
     MOVE 0 TO L-STATE
     CALL "PGB-SLOT" USING L-ID WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE PG-DANCE(WS-SLOT) TO L-STATE
     END-IF
     GOBACK.
 END PROGRAM PGB-DANCE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-AVOIDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AVOIDING             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AVOIDING.
     MOVE 0 TO L-AVOIDING
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         IF PG-AVOID(WS-SLOT) > 0 AND PG-AVOID-KIND(WS-SLOT) = 1
             MOVE 1 TO L-AVOIDING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-AVOIDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-REPEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY0                PIC X(48).
 01 WS-HIT                 BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-LIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND WS-BEST
     PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
         PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
             PERFORM VARYING WS-DY FROM -4 BY 1 UNTIL WS-DY > 4
                 COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DX
                 COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DY
                 COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DZ
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = 0
                     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY0
                     IF WS-KEY0(1:10) = "minecraft:"
                         MOVE WS-KEY0(11:38) TO WS-KEY
                     ELSE
                         MOVE WS-KEY0 TO WS-KEY
                     END-IF
                     MOVE 0 TO WS-HIT
                     IF L-KIND = 1
                         EVALUATE WS-KEY
                             WHEN "soul_fire" WHEN "soul_torch" WHEN "soul_lantern" WHEN "soul_wall_torch"
                                 MOVE 1 TO WS-HIT
                             WHEN "soul_campfire"
                                 CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
                                 MOVE 0 TO WS-LIT
                                 INSPECT WS-PROPS TALLYING WS-LIT FOR ALL "lit=true"
                                 IF WS-LIT > 0
                                     MOVE 1 TO WS-HIT
                                 END-IF
                         END-EVALUATE
                     ELSE
                         EVALUATE WS-KEY
                             WHEN "warped_fungus" WHEN "potted_warped_fungus" WHEN "nether_portal" WHEN "respawn_anchor"
                                 MOVE 1 TO WS-HIT
                         END-EVALUATE
                     END-IF
                     IF WS-HIT = 1
*>                       Nearest first by Manhattan distance (findBlocksInBoxByManhattanDistance, 44-6 section 4.1).
                         COMPUTE WS-D2 = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DY) + FUNCTION ABS(WS-DZ)
                         IF WS-BEST = 0 OR WS-D2 < WS-BEST
                             MOVE WS-D2 TO WS-BEST
                             MOVE 1 TO L-FOUND
                             MOVE WS-X TO L-X
                             MOVE WS-Y TO L-Y
                             MOVE WS-Z TO L-Z
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PGB-REPEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-ZOMB.
*> USING row, zombified row out, squared distance out: the nearest living zombified piglin or zoglin of the dimension within 16 blocks that the mob sees (NEAREST_VISIBLE_ZOMBIFIED, 4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND L-D2.
     MOVE 0 TO L-FOUND L-D2
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND WS-N NOT = L-ROW
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             IF WS-S > 0
                 IF SM-KEY(WS-S) = "zombified_piglin" OR SM-KEY(WS-S) = "zoglin"
                     COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 <= 256 AND (L-FOUND = 0 OR WS-D2 < L-D2)
                         COMPUTE WS-AY = EN-Y(L-ROW) + 1.5
                         COMPUTE WS-BY = EN-Y(WS-N) + 1
                         MOVE EN-X(L-ROW) TO WS-AX
                         MOVE EN-Z(L-ROW) TO WS-AZ
                         MOVE EN-X(WS-N) TO WS-BX
                         MOVE EN-Z(WS-N) TO WS-BZ
                         CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ WS-SEES
                         IF WS-SEES = 1
                             MOVE WS-N TO L-FOUND
                             MOVE WS-D2 TO L-D2
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGB-ZOMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-CELEBRATE.
*> USING piglin row, target row (the killed mob), draw (0 to 9): StartCelebratingIfTargetDead (300 ticks, adults): the place of the kill becomes CELEBRATE_LOCATION for 300 ticks and with
*> draw 0 (probability 1/10, wantsToDance for a hoglin target) the piglin dances: metadata 19 true to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET L-DRAW.
     IF EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 300 TO PG-CELEB(WS-SLOT)
     MOVE EN-X(L-TARGET) TO PG-CX(WS-SLOT)
     MOVE EN-Z(L-TARGET) TO PG-CZ(WS-SLOT)
     IF L-DRAW = 0
         IF PG-DANCE(WS-SLOT) NOT = 1
             MOVE 1 TO PG-DANCE(WS-SLOT)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
     ELSE
         IF PG-DANCE(WS-SLOT) = 2
             MOVE 0 TO PG-DANCE(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-CELEBRATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-CELEBRATE-STOP.
*> USING row: the celebration ends; a dancing piglin gets metadata 19 false.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE 0 TO PG-CELEB(WS-SLOT)
         IF PG-DANCE(WS-SLOT) = 1
             MOVE 2 TO PG-DANCE(WS-SLOT)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-CELEBRATE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY PGBRAIN.
 01 WS-M                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-SALT                BINARY-LONG VALUE 101.
 01 WS-BOUND               BINARY-LONG VALUE 41.
 01 WS-DRAW                BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ZD2                 FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-PAS-REG             BINARY-LONG VALUE 1.
 01 WS-PAS-NOW             BINARY-LONG.
 01 WS-PASSIVE             BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY32               PIC X(32).
 01 WS-LOVED               BINARY-LONG.
 01 WS-ADULT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "piglin" AND SM-KEY(WS-M) NOT = "hoglin"
         GOBACK
     END-IF
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
     MOVE 1 TO WS-ADULT
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 0 TO WS-ADULT
     END-IF
     IF PG-ATE(WS-SLOT) > 0
         SUBTRACT 1 FROM PG-ATE(WS-SLOT)
     END-IF
     IF PG-NOWALK(WS-SLOT) > 0
         SUBTRACT 1 FROM PG-NOWALK(WS-SLOT)
     END-IF
     IF PG-PACIFIED(WS-SLOT) > 0
         SUBTRACT 1 FROM PG-PACIFIED(WS-SLOT)
     END-IF
*>   The sensors run once every 20 ticks (4.1).
     IF FUNCTION MOD(CW-TIME + EN-ID(L-ROW), 20) = 0
         IF SM-KEY(WS-M) = "piglin"
             CALL "PGB-ZOMB" USING L-ROW WS-Z WS-ZD2
             IF WS-Z > 0 AND WS-ZD2 < 36
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
                 COMPUTE PG-AVOID(WS-SLOT) = 100 + WS-DRAW
                 MOVE 1 TO PG-AVOID-KIND(WS-SLOT)
                 MOVE EN-X(WS-Z) TO PG-AX(WS-SLOT)
                 MOVE EN-Z(WS-Z) TO PG-AZ(WS-SLOT)
                 MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
             END-IF
             MOVE 1 TO WS-KIND
         ELSE
             MOVE 2 TO WS-KIND
         END-IF
         CALL "PGB-REPEL" USING L-ROW WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
         MOVE 0 TO WS-PASSIVE
         IF WS-KIND = 2
*>           The behaviour needs ATTACK_TARGET registered (a hoglin always has it), PACIFIED absent and the repellent present (X1-PASSIVE-TEST, 44-x1 section 8.4).
             MOVE 0 TO WS-PAS-NOW
             IF PG-PACIFIED(WS-SLOT) > 0
                 MOVE 1 TO WS-PAS-NOW
             END-IF
             CALL "X1-PASSIVE-TEST" USING WS-PAS-REG WS-PAS-NOW WS-FOUND WS-PASSIVE
         END-IF
         IF WS-PASSIVE = 1
*>           BecomePassiveIfMemoryPresent(NEAREST_REPELLENT, 200): PACIFIED for 200 ticks and no attack target (44-6 section 6.2).
             MOVE 200 TO PG-PACIFIED(WS-SLOT)
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         END-IF
         IF WS-KIND = 2
             CALL "PGAI-HOGLIN-SENSE" USING L-ROW WS-SLOT WS-FOUND
         END-IF
         IF WS-FOUND = 1 AND (PG-AVOID(WS-SLOT) = 0 OR PG-AVOID-KIND(WS-SLOT) NOT = 1)
             MOVE 20 TO PG-AVOID(WS-SLOT)
             MOVE 2 TO PG-AVOID-KIND(WS-SLOT)
             COMPUTE PG-AX(WS-SLOT) = WS-RX + 0.5
             COMPUTE PG-AZ(WS-SLOT) = WS-RZ + 0.5
         END-IF
     END-IF
*>   A pacified hoglin has no target: its target finder is empty (44-6 section 6.2).
     IF PG-PACIFIED(WS-SLOT) > 0
         MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
     END-IF
*>   The celebration counts down; at its end a dancing piglin stops.
     IF PG-CELEB(WS-SLOT) > 0
         SUBTRACT 1 FROM PG-CELEB(WS-SLOT)
         IF PG-CELEB(WS-SLOT) = 0
             CALL "PGB-CELEBRATE-STOP" USING L-ROW
         END-IF
     END-IF
*>   AVOID: walk away from the point (a repellent only while there is no target: it is an IDLE and CELEBRATE behaviour).
     IF PG-AVOID(WS-SLOT) > 0
         SUBTRACT 1 FROM PG-AVOID(WS-SLOT)
         IF PG-AVOID-KIND(WS-SLOT) = 1 OR PG-AVOID-KIND(WS-SLOT) = 3 OR (EN-TARGET(L-ROW) = 0 AND EN-FOE(L-ROW) = 0)
*>           A hoglin retreats at 1.3 and keeps away from a piglin at 0.4 (44-6 section 6.1).
             IF SM-KEY(WS-M) = "hoglin" AND PG-AVOID-KIND(WS-SLOT) = 1
                 COMPUTE WS-SPEED = WS-SPEED * 1.3
             END-IF
             IF PG-AVOID-KIND(WS-SLOT) = 4
                 COMPUTE WS-SPEED = WS-SPEED * 0.4
             END-IF
             COMPUTE WS-DX = EN-X(L-ROW) - PG-AX(WS-SLOT)
             COMPUTE WS-DZ = EN-Z(L-ROW) - PG-AZ(WS-SLOT)
             COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
*>           SetWalkTargetAwayFrom acts only within its distance (44-6 section 5.3 step 2): 12 for a piglin's AVOID, 15 for a hoglin's, 8 for a repellent and for a piglin kept away from.
             MOVE 12 TO WS-RADIUS
             IF SM-KEY(WS-M) = "hoglin" AND PG-AVOID-KIND(WS-SLOT) = 1
                 MOVE 15 TO WS-RADIUS
             END-IF
             IF PG-AVOID-KIND(WS-SLOT) = 2 OR PG-AVOID-KIND(WS-SLOT) = 4
                 MOVE 8 TO WS-RADIUS
             END-IF
             IF WS-H < WS-RADIUS
                 IF WS-H < 0.01
                     MOVE 1 TO WS-DX
                     MOVE 0 TO WS-DZ
                     MOVE 1 TO WS-H
                 END-IF
                 COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
                 COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
                 MOVE 1 TO L-WALK
                 GOBACK
             END-IF
         END-IF
     END-IF
*>   A baby hoglin follows a visible adult hoglin (BabyFollowAdult, 44-6 section 5.7) while it has no target.
     IF SM-KEY(WS-M) = "hoglin" AND WS-ADULT = 0 AND EN-TARGET(L-ROW) = 0 AND EN-FOE(L-ROW) = 0
         CALL "PGAI-BABY-FOLLOW" USING L-ROW L-HX L-HZ L-WALK
     END-IF
     IF EN-TARGET(L-ROW) > 0 OR SM-KEY(WS-M) NOT = "piglin"
         GOBACK
     END-IF
*>   CELEBRATE: go to the place (radius 2 at speed 1.0; dancing radius 4 at speed 0.6, squared 0.36); inside the radius it stands.
     IF PG-CELEB(WS-SLOT) > 0
         MOVE 2 TO WS-RADIUS
         IF PG-DANCE(WS-SLOT) = 1
             MOVE 4 TO WS-RADIUS
             COMPUTE WS-SPEED = WS-SPEED * 0.36
         END-IF
         COMPUTE WS-DX = PG-CX(WS-SLOT) - EN-X(L-ROW)
         COMPUTE WS-DZ = PG-CZ(WS-SLOT) - EN-Z(L-ROW)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         MOVE 1 TO L-WALK
         IF WS-H > WS-RADIUS
             COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
             COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
         END-IF
         GOBACK
     END-IF
*>   ADMIRE_ITEM: GoToWantedItem (a loved item within 9 blocks while no loved item is held) and StopAdmiringIfTiredOfTryingToReachItem (200 ticks, then 200 ticks without walking).
     IF WS-ADULT = 1 AND EN-ADMIRE(L-ROW) = 0 AND PG-NOWALK(WS-SLOT) = 0
         MOVE 0 TO WS-BEST
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-ITEM-COUNT(WS-E) > 0
                 COMPUTE WS-D2 = (EN-X(WS-E) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-E) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-E) - EN-Z(L-ROW)) ** 2
                 IF WS-D2 < 81 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                     MOVE IT-KEY(EN-ITEM(WS-E) + 1) TO WS-KEY
                     IF WS-KEY(1:10) = "minecraft:"
                         MOVE WS-KEY(11:32) TO WS-KEY32
                     ELSE
                         MOVE WS-KEY(1:32) TO WS-KEY32
                     END-IF
                     CALL "PIGLIN-LOVED" USING WS-KEY32 WS-LOVED
                     IF WS-LOVED = 1
                         MOVE WS-E TO WS-BEST
                         MOVE WS-D2 TO WS-BEST-D2
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST = 0
             MOVE 0 TO PG-REACH(WS-SLOT)
         ELSE
             ADD 1 TO PG-REACH(WS-SLOT)
             IF PG-REACH(WS-SLOT) > 200
                 MOVE 0 TO PG-REACH(WS-SLOT)
                 MOVE 200 TO PG-NOWALK(WS-SLOT)
             ELSE
                 COMPUTE WS-DX = EN-X(WS-BEST) - EN-X(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-BEST) - EN-Z(L-ROW)
                 COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
                 IF WS-H > 0.1
                     COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
                     COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
                     MOVE 1 TO L-WALK
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-STEP.
