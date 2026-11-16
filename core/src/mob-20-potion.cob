*> The witch's thrown potions (docs/protocol/20 section 11, 17 section 3.15, 44 section 6.5, 25-5 section 8; lane 002-lane-mobsb5, T8910). State: PZ-ENTRY of EVKSTATE.cpy.
*>   WITCH-THROW-PICK USING raider target (0/1), target health (whole), distance, has slowness, has poison, has weakness, roll (thousandths), potion out
*>   POTION-SPEED USING distance, speed out        0.45 within 2 blocks, else 0.75
*>   POTION-AIM USING dx, dy, dz, distance, speed, vx out, vy out, vz out    the direction with y raised by distance x 0.2, scaled to the speed
*>   POTION-SPLASH USING dim, x, y, z, potion, owner entity id    the shatter: living entities within the box inflated by (4, 2, 4) and within distance 4 get intensity t = 1 - distance / 4
*>   POTION-LAUNCH USING dim, x, y, z, vx, vy, vz, potion, owner  adds a potion to the flight table (with a visible entity)
*>   POTIONS-TICK                                  one tick of every potion in flight (STDMOB-SPAWN-TICK): position += v, v x 0.99, vy -= 0.05; it shatters on a block or an entity
*>   WITCH-THROW USING witch row                   the ranged attack: the choice, the aim at the target's position, speed, inaccuracy 8, timer 60
*>   WITCH-THROW-STEP USING witch row, drinking     the ranged goal: with a target within 10 blocks in sight and the timer at 0 the witch throws; the timer counts down
*> Potions: 1 harming (instant_damage 6), 2 healing (instant_health 5), 3 regeneration (900), 4 slowness (1800), 5 poison (900), 6 weakness (1800); effects are applied as
*> (int)(duration x t + 0.5) unless that ends within 20 ticks; instant ones as (int)(t x 6 << amplifier + 0.5) (4 for healing).
*> Gaps: the potion colour and the splash level event 2002, the sounds, the potion item stack metadata of the visible entity, water bottles, the target's velocity in the aim,
*> the box of a mob taken as 0.6 x 1.8, a hit of the potion entity on a mob's real box, lingering potions and area effect clouds (lane mobsb6), the potion resistance of witches
*> (0.15 on magic damage), a witch healing raiders (the healable-raider target goal).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITCH-THROW-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-RAIDER                BINARY-LONG.
 01 L-HEALTH                BINARY-LONG.
 01 L-D                     FLOAT-LONG.
 01 L-SLOW                  BINARY-LONG.
 01 L-POISON                BINARY-LONG.
 01 L-WEAK                  BINARY-LONG.
 01 L-ROLL                  BINARY-LONG.
 01 L-POTION                BINARY-LONG.
 PROCEDURE DIVISION USING L-RAIDER L-HEALTH L-D L-SLOW L-POISON L-WEAK L-ROLL L-POTION.
     MOVE 1 TO L-POTION
     IF L-RAIDER = 1
         IF L-HEALTH <= 4
             MOVE 2 TO L-POTION
         ELSE
             MOVE 3 TO L-POTION
         END-IF
         GOBACK
     END-IF
     IF L-D >= 8 AND L-SLOW = 0
         MOVE 4 TO L-POTION
     ELSE
         IF L-HEALTH >= 8 AND L-POISON = 0
             MOVE 5 TO L-POTION
         ELSE
             IF L-D <= 3 AND L-WEAK = 0 AND L-ROLL < 250
                 MOVE 6 TO L-POTION
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WITCH-THROW-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-SPEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-D                     FLOAT-LONG.
 01 L-SPEED                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-D L-SPEED.
     IF L-D <= 2
         MOVE 0.45 TO L-SPEED
     ELSE
         MOVE 0.75 TO L-SPEED
     END-IF
     GOBACK.
 END PROGRAM POTION-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-AIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                    FLOAT-LONG.
 01 WS-LEN                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                    FLOAT-LONG.
 01 L-DY                    FLOAT-LONG.
 01 L-DZ                    FLOAT-LONG.
 01 L-D                     FLOAT-LONG.
 01 L-SPEED                 FLOAT-LONG.
 01 L-VX                    FLOAT-LONG.
 01 L-VY                    FLOAT-LONG.
 01 L-VZ                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-D L-SPEED L-VX L-VY L-VZ.
     COMPUTE WS-Y = L-DY + L-D * 0.2
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + WS-Y * WS-Y + L-DZ * L-DZ)
     IF WS-LEN = 0
         MOVE 0 TO L-VX L-VY L-VZ
     ELSE
         COMPUTE L-VX = L-DX / WS-LEN * L-SPEED
         COMPUTE L-VY = WS-Y / WS-LEN * L-SPEED
         COMPUTE L-VZ = L-DZ / WS-LEN * L-SPEED
     END-IF
     GOBACK.
 END PROGRAM POTION-AIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-EFFECT-OF.
*> USING potion, effect id out, amplifier out, duration out (0 = instant)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-POTION                BINARY-LONG.
 01 L-ID                    BINARY-LONG.
 01 L-AMP                   BINARY-LONG.
 01 L-DUR                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POTION L-ID L-AMP L-DUR.
     MOVE 0 TO L-AMP L-DUR
     EVALUATE L-POTION
         WHEN 1
             MOVE 6 TO L-ID
         WHEN 2
             MOVE 5 TO L-ID
         WHEN 3
             MOVE 9 TO L-ID
             MOVE 900 TO L-DUR
         WHEN 4
             MOVE 1 TO L-ID
             MOVE 1800 TO L-DUR
         WHEN 5
             MOVE 18 TO L-ID
             MOVE 900 TO L-DUR
         WHEN OTHER
             MOVE 17 TO L-ID
             MOVE 1800 TO L-DUR
     END-EVALUATE
     GOBACK.
 END PROGRAM POTION-EFFECT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-SPLASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-ID                   BINARY-LONG.
 01 WS-AMP                  BINARY-LONG.
 01 WS-DUR                  BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-O                    BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-MAPPED               BINARY-LONG.
 01 WS-AMOUNT               BINARY-LONG.
 01 WS-MILLI                BINARY-LONG.
 01 WS-RESULT               BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-FLAGS                BINARY-LONG VALUE 6.
 01 WS-MF                   BINARY-LONG VALUE 2.
 01 WS-HP                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     FLOAT-LONG.
 01 L-Y                     FLOAT-LONG.
 01 L-Z                     FLOAT-LONG.
 01 L-POTION                BINARY-LONG.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-POTION L-OWNER.
     CALL "POTION-EFFECT-OF" USING L-POTION WS-ID WS-AMP WS-DUR
     MOVE 0 TO WS-O
     IF L-OWNER > 0
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF EN-USED(WS-N) = 1 AND EN-ID(WS-N) = L-OWNER
                 MOVE WS-N TO WS-O
             END-IF
         END-PERFORM
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-DX = FUNCTION MAX(0, FUNCTION ABS(PL-X(WS-P) - L-X) - 0.3)
             COMPUTE WS-DZ = FUNCTION MAX(0, FUNCTION ABS(PL-Z(WS-P) - L-Z) - 0.3)
             COMPUTE WS-DY = FUNCTION MAX(0, FUNCTION MAX(PL-Y(WS-P) - L-Y, L-Y - (PL-Y(WS-P) + 1.8)))
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= 16
                 COMPUTE WS-T = (1 - FUNCTION SQRT(WS-D2) / 4) * 1000
                 IF WS-DUR = 0
                     IF L-POTION = 1
                         COMPUTE WS-AMOUNT = (WS-T * 6 + 500) / 1000
                         COMPUTE WS-MILLI = WS-AMOUNT * 1000
                         IF WS-O > 0
                             CALL "STDMOB-NAME" USING EN-TYPE(WS-O) PL-KILLER-NAME(WS-P) PL-KILLER-LENGTH(WS-P)
                             MOVE 0 TO PL-KILLER-ITEM-LENGTH(WS-P)
                             MOVE PL-KILLER-NAME(WS-P) TO PL-CREDIT-NAME(WS-P)
                             MOVE PL-KILLER-LENGTH(WS-P) TO PL-CREDIT-LENGTH(WS-P)
                         END-IF
                         CALL "HEALTH-HURT" USING WS-P WS-MILLI CAUSE-MOB L-OWNER WS-NO WS-RESULT
                     ELSE
                         COMPUTE WS-AMOUNT = (WS-T * 4 + 500) / 1000
                         MOVE PL-HEALTH(WS-P) TO WS-HP
                         COMPUTE PL-HEALTH(WS-P) = FUNCTION MIN(20, WS-HP + WS-AMOUNT)
                     END-IF
                 ELSE
                     COMPUTE WS-MAPPED = (WS-DUR * WS-T + 500) / 1000
                     IF WS-MAPPED > 20
                         CALL "EFFECT-ADD" USING WS-P WS-ID WS-AMP WS-MAPPED WS-FLAGS
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = L-DIM AND WS-N NOT = WS-O
             COMPUTE WS-DX = FUNCTION MAX(0, FUNCTION ABS(EN-X(WS-N) - L-X) - 0.3)
             COMPUTE WS-DZ = FUNCTION MAX(0, FUNCTION ABS(EN-Z(WS-N) - L-Z) - 0.3)
             COMPUTE WS-DY = FUNCTION MAX(0, FUNCTION MAX(EN-Y(WS-N) - L-Y, L-Y - (EN-Y(WS-N) + 1.8)))
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= 16
                 COMPUTE WS-T = (1 - FUNCTION SQRT(WS-D2) / 4) * 1000
                 IF WS-DUR = 0
                     CALL "MEF-INSTANT-T" USING WS-N WS-ID WS-AMP WS-T
                 ELSE
                     COMPUTE WS-MAPPED = (WS-DUR * WS-T + 500) / 1000
                     IF WS-MAPPED > 20
                         CALL "MEF-ADD" USING EN-ID(WS-N) WS-ID WS-AMP WS-MAPPED WS-FLAGS
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-SPLASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-LAUNCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-KEY                  PIC X(112) VALUE "minecraft:splash_potion".
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     FLOAT-LONG.
 01 L-Y                     FLOAT-LONG.
 01 L-Z                     FLOAT-LONG.
 01 L-VX                    FLOAT-LONG.
 01 L-VY                    FLOAT-LONG.
 01 L-VZ                    FLOAT-LONG.
 01 L-POTION                BINARY-LONG.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-POTION L-OWNER.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX OR WS-DONE = 1
         IF PZ-USED(WS-I) = 0
             MOVE 1 TO PZ-USED(WS-I)
             MOVE L-DIM TO PZ-DIM(WS-I)
             MOVE L-X TO PZ-X(WS-I)
             MOVE L-Y TO PZ-Y(WS-I)
             MOVE L-Z TO PZ-Z(WS-I)
             MOVE L-VX TO PZ-VX(WS-I)
             MOVE L-VY TO PZ-VY(WS-I)
             MOVE L-VZ TO PZ-VZ(WS-I)
             MOVE L-POTION TO PZ-KIND(WS-I)
             MOVE L-OWNER TO PZ-OWNER(WS-I)
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
             CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW PZ-ROW(WS-I)
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-LAUNCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTIONS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-SOLID                BINARY-LONG.
 01 WS-HIT                  BINARY-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-PITCH                FLOAT-SHORT VALUE 0.
 01 WS-GROUND               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         IF PZ-USED(WS-I) = 1
             COMPUTE WS-X = PZ-X(WS-I) + PZ-VX(WS-I)
             COMPUTE WS-Y = PZ-Y(WS-I) + PZ-VY(WS-I)
             COMPUTE WS-Z = PZ-Z(WS-I) + PZ-VZ(WS-I)
             COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
             COMPUTE WS-CY = FUNCTION INTEGER(WS-Y)
             COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
             CALL "GI-SOLID-CELL" USING PZ-DIM(WS-I) WS-CX WS-CY WS-CZ WS-SOLID
             MOVE WS-SOLID TO WS-HIT
*>           An entity (not the thrower, not another potion) within 0.25 + 0.3 horizontally.
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
                 IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = PZ-DIM(WS-I) AND PL-MODE(WS-P) NOT = 3
                         AND PL-ENTITY-ID(WS-P) NOT = PZ-OWNER(WS-I)
                     IF FUNCTION ABS(PL-X(WS-P) - WS-X) <= 0.55 AND FUNCTION ABS(PL-Z(WS-P) - WS-Z) <= 0.55
                             AND WS-Y >= PL-Y(WS-P) - 0.25 AND WS-Y <= PL-Y(WS-P) + 1.8
                         MOVE 1 TO WS-HIT
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-HIT = 1
                 CALL "POTION-SPLASH" USING PZ-DIM(WS-I) PZ-X(WS-I) PZ-Y(WS-I) PZ-Z(WS-I) PZ-KIND(WS-I) PZ-OWNER(WS-I)
                 IF PZ-ROW(WS-I) > 0
                     CALL "ENTITY-REMOVE" USING PZ-ROW(WS-I)
                 END-IF
                 MOVE 0 TO PZ-USED(WS-I)
             ELSE
                 MOVE WS-X TO PZ-X(WS-I)
                 MOVE WS-Y TO PZ-Y(WS-I)
                 MOVE WS-Z TO PZ-Z(WS-I)
                 COMPUTE PZ-VX(WS-I) = PZ-VX(WS-I) * 0.99
                 COMPUTE PZ-VY(WS-I) = PZ-VY(WS-I) * 0.99 - 0.05
                 COMPUTE PZ-VZ(WS-I) = PZ-VZ(WS-I) * 0.99
                 IF PZ-ROW(WS-I) > 0
                     CALL "ENTITY-MOVE" USING PZ-ROW(WS-I) WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTIONS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITCH-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY EVKSTATE.
 01 WS-P                    BINARY-LONG.
 01 WS-RAIDER               BINARY-LONG VALUE 0.
 01 WS-HEALTH               BINARY-LONG.
 01 WS-D                    FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-SLOW                 BINARY-LONG.
 01 WS-POISON               BINARY-LONG.
 01 WS-WEAK                 BINARY-LONG.
 01 WS-ROLL                 BINARY-LONG.
 01 WS-POTION               BINARY-LONG.
 01 WS-SPEED                FLOAT-LONG.
 01 WS-VX                   FLOAT-LONG.
 01 WS-VY                   FLOAT-LONG.
 01 WS-VZ                   FLOAT-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-LEFT                 BINARY-LONG.
 01 WS-E-SLOW               BINARY-LONG VALUE 1.
 01 WS-E-POISON             BINARY-LONG VALUE 18.
 01 WS-E-WEAK               BINARY-LONG VALUE 17.
 01 WS-SALT                 BINARY-LONG VALUE 78.
 01 WS-B1000                BINARY-LONG VALUE 1000.
 01 WS-R1                   BINARY-LONG.
 01 WS-R2                   BINARY-LONG.
 01 WS-HP                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0
         GOBACK
     END-IF
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(WS-P) + 1.62 - 1.1 - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "EFFECT-LEVEL" USING WS-P WS-E-SLOW WS-LEVEL WS-LEFT
     MOVE 0 TO WS-SLOW WS-POISON WS-WEAK
     IF WS-LEVEL > 0
         MOVE 1 TO WS-SLOW
     END-IF
     CALL "EFFECT-LEVEL" USING WS-P WS-E-POISON WS-LEVEL WS-LEFT
     IF WS-LEVEL > 0
         MOVE 1 TO WS-POISON
     END-IF
     CALL "EFFECT-LEVEL" USING WS-P WS-E-WEAK WS-LEVEL WS-LEFT
     IF WS-LEVEL > 0
         MOVE 1 TO WS-WEAK
     END-IF
     MOVE PL-HEALTH(WS-P) TO WS-HP
     COMPUTE WS-HEALTH = FUNCTION INTEGER(WS-HP)
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-ROLL
     CALL "WITCH-THROW-PICK" USING WS-RAIDER WS-HEALTH WS-D WS-SLOW WS-POISON WS-WEAK WS-ROLL WS-POTION
     CALL "POTION-SPEED" USING WS-D WS-SPEED
     CALL "POTION-AIM" USING WS-DX WS-DY WS-DZ WS-D WS-SPEED WS-VX WS-VY WS-VZ
*>   Inaccuracy 8.0: each component varied by the triangle of 0.0172275 x 8 (as the arrows of STDMOB-SHOOT) in units of the speed.
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
     COMPUTE WS-VX = WS-VX + (WS-R1 - WS-R2) / 1000 * 0.13782 * WS-SPEED
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
     COMPUTE WS-VY = WS-VY + (WS-R1 - WS-R2) / 1000 * 0.13782 * WS-SPEED
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
     COMPUTE WS-VZ = WS-VZ + (WS-R1 - WS-R2) / 1000 * 0.13782 * WS-SPEED
     MOVE EN-X(L-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(L-ROW) + 1.62 - 0.1
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "POTION-LAUNCH" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-POTION EN-ID(L-ROW)
     MOVE 60 TO EN-SHOOT-TIME(L-ROW)
     GOBACK.
 END PROGRAM WITCH-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITCH-THROW-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                    BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-AX                   FLOAT-LONG.
 01 WS-AY                   FLOAT-LONG.
 01 WS-AZ                   FLOAT-LONG.
 01 WS-TY                   FLOAT-LONG.
 01 WS-SEES                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-SHOOT-TIME(L-ROW) > 0
         SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0 OR EN-SHOOT-TIME(L-ROW) > 0
         GOBACK
     END-IF
     COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     IF WS-D2 > 100
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.62
     MOVE EN-Z(L-ROW) TO WS-AZ
     COMPUTE WS-TY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
     IF WS-SEES = 1
         CALL "WITCH-THROW" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM WITCH-THROW-STEP.
