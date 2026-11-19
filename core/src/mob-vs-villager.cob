*> Hostile mobs against villagers (docs/protocol/20 sections 4, 13.1 and 13.6; lane 002-lane-mobsb5, T8906; the caller of ZV-KILLED of T8803).
*>   MOBVS-TICK USING mob row, table row, hx out, hz out, walk out
*> The zombie family (zombie, husk, drowned, zombie villager), vindicators and ravagers, with no player target, take the nearest live villager or wandering trader within the follow
*> range as their foe (illagers and ravagers skip baby villagers, a vindicator and a ravager must see the target; the zombie need not), walk to it (STDMOB-HEAD) and in reach hit it with
*> the attack damage on the attack timer (EN-PET-CD). A vindicator and a ravager also take an iron golem as their foe (20 sections 13.1 and 13.6, must see). A killing blow by the zombie family goes through ZV-KILL-RULE: when it converts, ZV-KILLED replaces the villager.
*> Gaps: the target is not kept between ticks (the nearest is picked again), the attack animation event, no knockback, the persistent-anger and alert-others lists, pillagers
*> and evokers (ranged and spells) do not attack villagers here, no hurt-by response of the villager other than the panic of its sensors, a wandering trader is not converted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOBVS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY RULES.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-F                    BINARY-LONG.
 01 WS-ZOMBIE               BINARY-LONG.
 01 WS-ILLAGER              BINARY-LONG.
 01 WS-SEE                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-RANGE                FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-REACH                FLOAT-LONG.
 01 WS-AX                   FLOAT-LONG.
 01 WS-AY                   FLOAT-LONG.
 01 WS-AZ                   FLOAT-LONG.
 01 WS-BX                   FLOAT-LONG.
 01 WS-BY                   FLOAT-LONG.
 01 WS-BZ                   FLOAT-LONG.
 01 WS-SEES                 BINARY-LONG.
 01 WS-GX                   BINARY-LONG.
 01 WS-GY                   BINARY-LONG.
 01 WS-GZ                   BINARY-LONG.
 01 WS-ARRIVED              BINARY-LONG.
 01 WS-DAMAGE               BINARY-LONG.
 01 WS-COIN                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 75.
 01 WS-BOUND                BINARY-LONG VALUE 2.
 01 WS-YES                  BINARY-LONG.
 01 WS-CONVERTED            BINARY-LONG.
 01 WS-KEY24                PIC X(24).
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-FOE-KEY              PIC X(24).
 01 WS-JOHNNY               BINARY-LONG.
 01 WS-CAND                 BINARY-LONG.
 01 WS-BPRIO                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-M                     BINARY-LONG.
 01 L-HX                    FLOAT-LONG.
 01 L-HZ                    FLOAT-LONG.
 01 L-WALK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     MOVE 0 TO WS-ZOMBIE WS-ILLAGER WS-SEE
     EVALUATE SM-KEY(L-M)
         WHEN "zombie" WHEN "husk" WHEN "drowned" WHEN "zombie_villager"
             MOVE 1 TO WS-ZOMBIE
         WHEN "vindicator"
             MOVE 1 TO WS-ILLAGER
             MOVE 1 TO WS-SEE
         WHEN "ravager"
             MOVE 1 TO WS-ILLAGER
             MOVE 1 TO WS-SEE
         WHEN "piglin" WHEN "hoglin" WHEN "zoglin"
             IF EN-FOE(L-ROW) = 0
                 GOBACK
             END-IF
         WHEN OTHER
             GOBACK
     END-EVALUATE
     IF EN-PET-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     END-IF
     COMPUTE WS-RANGE = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
     MOVE 0 TO WS-F WS-JOHNNY
*>   Johnny (20 section 13.1, goal 4): any living entity that is not an illager friend is a foe, after the others.
     IF SM-KEY(L-M) = "vindicator"
         CALL "JOHNNY-IS" USING L-ROW WS-JOHNNY
     END-IF
*>   A foe set by a hunt or a retaliation (EN-FOE) comes first.
     IF EN-FOE(L-ROW) > 0
         MOVE EN-FOE(L-ROW) TO WS-N
         IF EN-USED(WS-N) = 1 AND EN-ID(WS-N) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             MOVE WS-N TO WS-F
         ELSE
             MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     IF WS-F = 0 AND WS-ZOMBIE + WS-ILLAGER = 0
         GOBACK
     END-IF
     IF WS-F = 0
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             IF WS-S > 0
                 MOVE 0 TO WS-CAND
                 IF SM-KEY(WS-S) = "villager" OR "wandering_trader" OR (SM-KEY(WS-S) = "iron_golem" AND (SM-KEY(L-M) = "vindicator" OR "ravager"))
                     MOVE 1 TO WS-CAND
                 END-IF
                 IF WS-CAND = 0 AND WS-JOHNNY = 1 AND WS-N NOT = L-ROW
                         AND NOT (SM-KEY(WS-S) = "evoker" OR "illusioner" OR "pillager" OR "vindicator")
                     MOVE 2 TO WS-CAND
                 END-IF
                 IF WS-CAND > 0
                     COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 <= WS-RANGE AND (WS-F = 0 OR WS-CAND < WS-BPRIO OR (WS-CAND = WS-BPRIO AND WS-D2 < WS-BEST))
                         IF NOT (WS-ILLAGER = 1 AND EN-MOBAGE(WS-N) < 0 AND (SM-KEY(WS-S) = "villager" OR "wandering_trader"))
                             MOVE 1 TO WS-SEES
                             IF WS-SEE = 1
                                 COMPUTE WS-AX = EN-X(L-ROW)
                                 COMPUTE WS-AY = EN-Y(L-ROW) + 1.5
                                 COMPUTE WS-AZ = EN-Z(L-ROW)
                                 COMPUTE WS-BY = EN-Y(WS-N) + 1.5
                                 CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ EN-X(WS-N) WS-BY EN-Z(WS-N) WS-SEES
                             END-IF
                             IF WS-SEES = 1
                                 MOVE WS-N TO WS-F
                                 MOVE WS-D2 TO WS-BEST
                                 MOVE WS-CAND TO WS-BPRIO
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     END-IF
     IF WS-F = 0
         GOBACK
     END-IF
     MOVE 1 TO L-WALK
     COMPUTE WS-DX = EN-X(WS-F) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(WS-F) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-F) - EN-Z(L-ROW)
     COMPUTE WS-REACH = SM-REACH-MILLI / 1000
     IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
         COMPUTE WS-GX = FUNCTION INTEGER(EN-X(WS-F))
         COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-F))
         COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(WS-F))
         CALL "STDMOB-HEAD" USING L-ROW L-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
     END-IF
     IF EN-PET-CD(L-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
             AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
         MOVE SM-ATTACK-TICKS TO EN-PET-CD(L-ROW)
         CALL "STDMOB-ATTACK-DAMAGE" USING L-ROW L-M WS-DAMAGE
         MOVE 0 TO WS-CONVERTED
         CALL "STDMOB-INDEX" USING EN-TYPE(WS-F) WS-S
         MOVE SM-KEY(WS-S) TO WS-FOE-KEY
         IF WS-ZOMBIE = 1 AND WS-FOE-KEY = "villager" AND WS-DAMAGE >= EN-HEALTH(WS-F)
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-COIN
             MOVE SM-KEY(L-M) TO WS-KEY24
             CALL "ZV-KILL-RULE" USING BW-DIFFICULTY WS-COIN WS-KEY24 WS-YES
             IF WS-YES = 1
                 CALL "ZV-KILLED" USING WS-F L-ROW WS-CONVERTED
             END-IF
         END-IF
         CALL "MOB-ATTACK-EVENT" USING L-ROW
         IF WS-CONVERTED = 0
             CALL "HEALTH-MOB-DAMAGE" USING WS-F WS-DAMAGE CAUSE-MOB WS-NONE
             CALL "MOB-HURT-BY-MOB" USING WS-F L-ROW
         END-IF
*>       A hoglin or zoglin that is hit by a mob turns on it; a piglin's kill restarts its hunting gap.
         IF WS-FOE-KEY = "hoglin" OR "zoglin"
             IF EN-FOE(WS-F) = 0
                 MOVE L-ROW TO EN-FOE(WS-F)
                 MOVE EN-ID(L-ROW) TO EN-FOE-ID(WS-F)
             END-IF
         END-IF
         IF SM-KEY(L-M) = "piglin" AND EN-HEALTH(WS-F) = 0
             CALL "PIGLIN-HUNT-DONE" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOBVS-TICK.
