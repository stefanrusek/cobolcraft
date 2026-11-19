*> The firework rocket and the lightning bolt of lane 002-lane-mobsb6 (21 sections 8.6 and 8.7, 17 section 3.13, 44 part 9 section 2). Rocket (PJ-KIND 8): PJ-I1 life, PJ-I2 lifetime
*> 10 x (flight duration + 1) + nextInt(6) + nextInt(7), PJ-I3 the number of explosion stars, PJ-I4 the attached entity id (0 none). It starts at (0, 0.05, 0) and moves by its velocity; when the
*> life passes the lifetime it explodes: Entity Event 17 to the viewers, the damage D = 5 + 2 x stars (0 without stars) to the attached entity, and D x sqrt((5 - distance) / 5) to the other living
*> entities within 5 blocks that the rocket sees (the distance and the sight line go to the entity's mid height); mobs lose whole points (rounded), players are hurt through HEALTH-HURT
*> (CAUSE-EXPLOSION: the fireworks damage type does not exist here).
*> PJ-I5 1: shot at an angle (no acceleration). Gaps: the horizontal-collision factor of the acceleration, the launch noise, riding an elytra boost (gliding does not exist in the core), the star effects (colour, shape, trail, twinkle,
*> particles), sampled collider heights, the explosion sounds, the firework item with stars (item stacks carry no components, so a player's rocket has duration 1 and no star), and use
*> on a block.
*>
*>   FIREWORK-SPAWN USING dim, x, y, z (FLOAT-LONG), flight duration, stars, attached entity id, owner entity id, row out
*>   FIREWORK-EXPLODE USING tracker row
*>   FIREWORK-STEP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIREWORK-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:firework_rocket".
 01 WS-KIND                BINARY-LONG VALUE 8.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.05.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9081.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-R6                  BINARY-LONG.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-R7                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-STARS                BINARY-LONG.
 01 L-ATTACHED             BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DURATION L-STARS L-ATTACHED L-OWNER L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ L-OWNER L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "XP-RANDOM" USING WS-SALT WS-SIX WS-R6
     CALL "XP-RANDOM" USING WS-SALT WS-SEVEN WS-R7
     CALL "TOOL-FIREWORK-LIFETIME" USING L-DURATION WS-R6 WS-R7 PJ-I2(WS-SLOT)
*>   Initial velocity (21 section 8.7): (triangle(0, 0.002297), 0.05, triangle(0, 0.002297)), triangle(0, m) = m * (nextDouble - nextDouble).
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-T1
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-T2
     COMPUTE EN-VX(L-ROW) = 0.002297 * (WS-T1 - WS-T2) / 1000
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-T1
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-T2
     COMPUTE EN-VZ(L-ROW) = 0.002297 * (WS-T1 - WS-T2) / 1000
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE L-STARS TO PJ-I3(WS-SLOT)
     MOVE L-ATTACHED TO PJ-I4(WS-SLOT)
     GOBACK.
 END PROGRAM FIREWORK-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIREWORK-HURT.
*> USING slot, tracker row of the rocket, victim tracker row, victim player row (one 0), amount in thousandths: one victim of the explosion.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY RULES.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-EXPLOSION.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-POINTS              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OWNER-ROW           BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-VICTIM               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-VICTIM L-PLAYER L-AMOUNT.
     MOVE 0 TO WS-OWNER-ROW
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = PJ-OWNER(L-SLOT) AND PJ-OWNER(L-SLOT) > 0
             MOVE WS-P TO WS-OWNER-ROW
         END-IF
     END-PERFORM
     IF L-PLAYER > 0
         CALL "HEALTH-HURT" USING L-PLAYER L-AMOUNT WS-CAUSE PJ-OWNER(L-SLOT) WS-OWNER-ROW WS-RESULT
     ELSE
         COMPUTE WS-POINTS = FUNCTION INTEGER(L-AMOUNT / 1000 + 0.5)
         IF WS-POINTS > 0
             MOVE 0 TO EN-HURT(L-VICTIM)
             CALL "HEALTH-MOB-DAMAGE" USING L-VICTIM WS-POINTS WS-CAUSE WS-OWNER-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FIREWORK-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIREWORK-EXPLODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-SLOT                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 17.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-EV-EXPLODE          PIC X(32) VALUE "explode".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-RX
     MOVE EN-Y(L-ROW) TO WS-RY
     MOVE EN-Z(L-ROW) TO WS-RZ
     MOVE EN-DIM(L-ROW) TO WS-DIM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
*>   FireworkRocketEntity.explode: explode at the rocket's position with the owner as the source, after entity event 17 and before the damage (30-8 14.2.4)
     CALL "GAME-EVENT-OWNED" USING WS-EV-EXPLODE L-ROW PJ-OWNER(WS-SLOT)
     MOVE 0 TO WS-D
     IF PJ-I3(WS-SLOT) > 0
         CALL "TOOL-FIREWORK-DAMAGE" USING PJ-I3(WS-SLOT) WS-D
     END-IF
     IF WS-D > 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = WS-DIM AND PL-MODE(WS-P) < 3
                 MOVE PL-ENTITY-ID(WS-P) TO WS-ID
                 COMPUTE WS-EY = PL-Y(WS-P) + 0.9
                 COMPUTE WS-DIST = FUNCTION SQRT((PL-X(WS-P) - WS-RX) ** 2 + (WS-EY - WS-RY) ** 2 + (PL-Z(WS-P) - WS-RZ) ** 2)
                 EVALUATE TRUE
                     WHEN WS-ID = PJ-I4(WS-SLOT)
                         CALL "FIREWORK-HURT" USING WS-SLOT WS-NONE WS-P WS-D
                     WHEN WS-DIST < 5
                         CALL "MOB-SEES" USING WS-DIM WS-RX WS-RY WS-RZ PL-X(WS-P) WS-EY PL-Z(WS-P) WS-SEES
                         IF WS-SEES = 1
                             COMPUTE WS-AMOUNT = FUNCTION INTEGER(WS-D * FUNCTION SQRT((5 - WS-DIST) / 5))
                             CALL "FIREWORK-HURT" USING WS-SLOT WS-NONE WS-P WS-AMOUNT
                         END-IF
                 END-EVALUATE
             END-IF
         END-PERFORM
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = WS-DIM AND EN-HEALTH(WS-E) > 0
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
                 IF WS-M > 0
                     COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-EY = EN-Y(WS-E) + WS-H / 2
                     COMPUTE WS-DIST = FUNCTION SQRT((EN-X(WS-E) - WS-RX) ** 2 + (WS-EY - WS-RY) ** 2 + (EN-Z(WS-E) - WS-RZ) ** 2)
                     EVALUATE TRUE
                         WHEN EN-ID(WS-E) = PJ-I4(WS-SLOT)
                             CALL "FIREWORK-HURT" USING WS-SLOT WS-E WS-NONE WS-D
                         WHEN WS-DIST < 5
                             CALL "MOB-SEES" USING WS-DIM WS-RX WS-RY WS-RZ EN-X(WS-E) WS-EY EN-Z(WS-E) WS-SEES
                             IF WS-SEES = 1
                                 COMPUTE WS-AMOUNT = FUNCTION INTEGER(WS-D * FUNCTION SQRT((5 - WS-DIST) / 5))
                                 CALL "FIREWORK-HURT" USING WS-SLOT WS-E WS-NONE WS-AMOUNT
                             END-IF
                     END-EVALUATE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM FIREWORK-EXPLODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIREWORK-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     ADD 1 TO PJ-I1(WS-SLOT)
*>   Projectile.tick first: projectile_shoot on the first tick at the rocket's position with the owner as the source (30-8 14.2.1)
     IF PJ-I1(WS-SLOT) = 1
         CALL "GAME-EVENT-SHOOT" USING L-ROW PJ-OWNER(WS-SLOT)
     END-IF
     IF PJ-I1(WS-SLOT) > PJ-I2(WS-SLOT)
         CALL "FIREWORK-EXPLODE" USING L-ROW
         GOBACK
     END-IF
*>   A rocket attached to a gliding player rides along and pushes it (17 section 3.13; RANGED-ROCKET-BOOST, ranged-glide.cob).
     IF PJ-I4(WS-SLOT) > 0
         CALL "RANGED-ROCKET-BOOST" USING L-ROW PJ-I4(WS-SLOT)
     END-IF
*>   A rocket that is not attached to an entity (PJ-I4) and was not shot at an angle (PJ-I5, the crossbow and the dispenser) accelerates (21 section 8.7): horizontally by 15 percent a tick,
*>   upward by 0.04 a tick; it then moves by the new velocity and keeps it. (The factor 1.0 of a rocket that had a horizontal collision is not modelled: the step does not collide.)
     IF PJ-I4(WS-SLOT) = 0 AND PJ-I5(WS-SLOT) = 0
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 1.15
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.04
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 1.15
     END-IF
     COMPUTE EN-X(L-ROW) = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE EN-Z(L-ROW) = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "THROWN-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM FIREWORK-STEP.
