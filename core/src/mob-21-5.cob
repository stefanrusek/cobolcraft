*> Nether mobs (002-lane-mobsfull-h12; docs/protocol/21 section 5). The rows are core/copy/MOB21ROWS2.cpy. No Nether dimension exists in worldgen yet: the logic
*> works wherever the mobs exist (/summon, the spawner API with an explicit dimension) and the natural entries of 21 section 3.4 are data (SM-SPAWN > 0).
*>
*> Anger (5.5.3 zombified piglin, 5.5.1 piglin): EN-ANGER holds the ticks of anger left, EN-TARGET the player it is angry at. A mob of SM-NEUTRAL 3 takes no
*> target of its own: it is angered only by a hit of a player (NETHER-HURT) or by the alert of another one (NETHER-ALERT).
*>
*> Entry points:
*>   NETHER-ANGER-TICKS USING tracker row, ticks out      the duration of a new anger: 20 to 39 whole seconds (uniform; hash of the entity id and the time)
*>   NETHER-HURT USING tracker row, attacker player row   called for every hit by a player: an anger-neutral mob becomes angry at the attacker and alerts the others
*>   NETHER-ALERT USING tracker row, player row           every other mob of the same type within the follow range (box: horizontal range, 10 vertical) without a target
*>                                                        takes the anger and the target (alertOthers); the caller's EN-ALERT is set to 80 to 120 ticks
*>   NETHER-AGGRO USING tracker row, table row            the target step of an anger-neutral mob: counts the anger down, alerts again every 4 to 6 seconds, drops the
*>                                                        target when it is gone, not alive, not in survival, in another dimension or out of range

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-ANGER-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF SM-NEUTRAL(WS-M) = 4
*>       The piglin's ANGER_DURATION (21 section 5.5.1).
         MOVE 600 TO L-TICKS
         GOBACK
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 41 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-SECONDS = 20 + FUNCTION MOD(WS-R, 20)
     COMPUTE L-TICKS = 20 * WS-SECONDS
     GOBACK.
 END PROGRAM NETHER-ANGER-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-ALERT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-KIN                 BINARY-LONG.
 01 WS-OM                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 43 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE EN-ALERT(L-ROW) = 80 + FUNCTION MOD(WS-R, 41)
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         MOVE 0 TO WS-KIN
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = EN-TYPE(L-ROW)
             MOVE 1 TO WS-KIN
         END-IF
*>       The anger of a piglin reaches every adult piglin and brute around it (broadcastAngerTarget, 44-6 section 2.5).
         IF EN-USED(WS-E) = 1 AND SM-KEY(WS-M) = "piglin" AND EN-MOBAGE(WS-E) >= 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-OM
             IF WS-OM > 0
                 IF SM-KEY(WS-OM) = "piglin_brute" OR (SM-KEY(WS-OM) = "piglin" AND EN-MOBAGE(L-ROW) >= 0)
                     MOVE 1 TO WS-KIN
                 END-IF
             END-IF
         END-IF
         IF WS-E NOT = L-ROW AND WS-KIN = 1 AND EN-HEALTH(WS-E) > 0
                 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-TARGET(WS-E) = 0 AND EN-TAMED(WS-E) = 0
             COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
             COMPUTE WS-DY = FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
             MOVE 1 TO WS-SEES
             IF SM-KEY(WS-M) = "bee"
*>               BeeHurtByOtherGoal alerts only bees the angry bee has a line of sight to (44 part 4 section 15); eyes taken 0.3 above the feet (stand-in).
                 COMPUTE WS-AY = EN-Y(L-ROW) + 0.3
                 COMPUTE WS-BY = EN-Y(WS-E) + 0.3
                 MOVE EN-X(L-ROW) TO WS-AX
                 MOVE EN-Z(L-ROW) TO WS-AZ
                 MOVE EN-X(WS-E) TO WS-BX
                 MOVE EN-Z(WS-E) TO WS-BZ
                 CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ WS-SEES
             END-IF
             IF WS-DX <= SM-FOLLOW(WS-M) AND WS-DZ <= SM-FOLLOW(WS-M) AND WS-DY <= 10 AND WS-SEES = 1
                 CALL "NETHER-ANGER-TICKS" USING WS-E WS-TICKS
                 MOVE WS-TICKS TO EN-ANGER(WS-E)
                 MOVE L-PLAYER TO EN-TARGET(WS-E)
                 MOVE PL-ENTITY-ID(L-PLAYER) TO EN-TARGET-ID(WS-E)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-ALERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-AVOID-KIND          BINARY-LONG VALUE 3.
 01 WS-BABY-TICKS          BINARY-LONG VALUE 100.
 01 WS-HANDLED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) = "hoglin"
         CALL "PGAI-UNPACIFY" USING L-ROW
     END-IF
     IF SM-KEY(WS-M) = "piglin" AND EN-MOBAGE(L-ROW) < 0
*>       A baby avoids its attacker for 100 ticks and gets no anger itself; the others are told (44-6 section 2.3 step 6).
         CALL "PGB-AVOID-SET" USING L-ROW WS-AVOID-KIND PL-X(L-ATTACKER) PL-Z(L-ATTACKER) WS-BABY-TICKS
         CALL "NETHER-ALERT" USING L-ROW L-ATTACKER
         GOBACK
     END-IF
*>   An adult piglin or a brute (44-6 sections 2.3 to 2.5): the end of a retreat, the retaliation distance rule and universal_anger.
     IF SM-KEY(WS-M) = "piglin" OR SM-KEY(WS-M) = "piglin_brute"
         CALL "PGAI-HURT-BY-PLAYER" USING L-ROW L-ATTACKER WS-HANDLED
         IF WS-HANDLED = 1
             GOBACK
         END-IF
     END-IF
     IF SM-KEY(WS-M) = "piglin_brute"
*>       A brute hit by a player takes it as its target and tells the piglins around it.
         MOVE L-ATTACKER TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(L-ATTACKER) TO EN-TARGET-ID(L-ROW)
         CALL "NETHER-ALERT" USING L-ROW L-ATTACKER
         GOBACK
     END-IF
     IF SM-NEUTRAL(WS-M) = 3 OR SM-NEUTRAL(WS-M) = 4 OR SM-NEUTRAL(WS-M) = 5 OR (SM-NEUTRAL(WS-M) = 6 AND EN-TAMED(L-ROW) = 0)
         CALL "NETHER-ANGER-TICKS" USING L-ROW WS-TICKS
         MOVE WS-TICKS TO EN-ANGER(L-ROW)
         MOVE L-ATTACKER TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(L-ATTACKER) TO EN-TARGET-ID(L-ROW)
         CALL "NETHER-ALERT" USING L-ROW L-ATTACKER
     END-IF
     GOBACK.
 END PROGRAM NETHER-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-AGGRO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-AVOIDING            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     IF SM-NEUTRAL(L-M) = 4
         CALL "PGB-AVOIDING" USING L-ROW WS-AVOIDING
         IF WS-AVOIDING = 1
*>           Near a zombified piglin or zoglin the piglin has no target (44-6 section 2.2 step 1).
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
             GOBACK
         END-IF
     END-IF
     IF SM-NEUTRAL(L-M) = 4 AND EN-ANGER(L-ROW) = 0
*>       A calm piglin attacks the nearest player in range that wears no golden armor.
         MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) WS-BEST
         COMPUTE WS-LIMIT = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 CALL "NETHER-GOLD-WORN" USING WS-P WS-GOLD
                 COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
                     + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                 IF WS-GOLD = 0 AND WS-D2 <= WS-LIMIT AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                     MOVE WS-P TO WS-BEST
                     MOVE WS-D2 TO WS-BEST-D2
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST > 0
             MOVE WS-BEST TO EN-TARGET(L-ROW)
             MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
         END-IF
         GOBACK
     END-IF
     IF EN-ANGER(L-ROW) > 0
         SUBTRACT 1 FROM EN-ANGER(L-ROW)
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-LIMIT = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
             + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ROW)
                 OR PL-STATE(WS-P) NOT = PS-ALIVE OR PL-MODE(WS-P) NOT = 0
                 OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW) OR WS-D2 > WS-LIMIT
             MOVE 0 TO EN-ANGER(L-ROW)
         END-IF
     END-IF
     IF EN-ANGER(L-ROW) = 0
         MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) EN-ALERT(L-ROW)
         GOBACK
     END-IF
     IF SM-NEUTRAL(L-M) = 3 OR SM-NEUTRAL(L-M) = 5
         IF EN-ALERT(L-ROW) > 0
             SUBTRACT 1 FROM EN-ALERT(L-ROW)
         END-IF
         IF EN-ALERT(L-ROW) = 0
             CALL "NETHER-ALERT" USING L-ROW WS-P
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NETHER-AGGRO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GOLD-WORN.
*> USING player row, worn out (BINARY-LONG): 1 when any of the four armor slots holds a golden piece (tag piglin_safe_armor, 21 section 5.5.1), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY CITEMS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-WORN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-WORN.
     MOVE 0 TO L-WORN
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         MOVE MN-EQUIP-ITEM(L-PLAYER, WS-SLOT) TO WS-ITEM
         IF MN-EQUIP-COUNT(L-PLAYER, WS-SLOT) > 0 AND WS-ITEM > 0 AND WS-ITEM < IT-COUNT
             IF IT-KEY(WS-ITEM + 1)(1:7) = "golden_" OR IT-KEY(WS-ITEM + 1)(1:17) = "minecraft:golden_"
                 MOVE 1 TO L-WORN
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-GOLD-WORN.
