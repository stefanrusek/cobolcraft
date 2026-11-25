*> The spear's jab (docs/protocol/17 section 3.12 piercing weapon, 2.4 spear table, 6.3 Lunge, 4.1 attack strength, 5.1 durability; lane 002-lane-p46e, T27014). The Attack packet never
*> runs the melee rules for a spear (HEALTH-ATTACK returns at once, TOOL-SPEAR-ATTACK-IGNORED). Player Action STAB (8) is the jab (RANGED-STAB): refused until the attack strength reaches the
*> minimum attack charge 1.0 (TOOL-SPEAR-JAB); then every entity whose box (inflated by the hitbox margin 0.125) meets the look ray between the minimum reach 2.0 and the maximum reach (4.5, a
*> creative player's 6.5) is stabbed: a mob or a fighting player takes the attack damage of the spear (the attribute value with Strength and Weakness) as a player attack, the spear takes 1
*> durability and the player 0.1 exhaustion for each entity hit; the stab resets the attack strength (TS-LAST-ATTACK). Lunge L then pushes the player horizontally along the look vector by
*> 0.458 L (Set Entity Motion), costs 4.0 L exhaustion and 1 more durability unless the player rides, glides, is in water or (survival) has less than 7 food. Not done: blocks in the way do
*> not stop the ray (the section does not say they do), the knockback and the dismount of stabAttack (the spear has deals_knockback and dismounts false of its own), the
*> kinetic charge attack of Use Item, the sound, the swing animation.
*>
*>   RANGED-RAY-BOX USING eye x y z, look dx dy dz, box lowest x y z, highest x y z (FLOAT-LONG), near out, far out, hit out   the slab test of a ray against a box
*>   RANGED-STAB USING player row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-RAY-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-TMP                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OX                   FLOAT-LONG.
 01 L-OY                   FLOAT-LONG.
 01 L-OZ                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-MINX                 FLOAT-LONG.
 01 L-MINY                 FLOAT-LONG.
 01 L-MINZ                 FLOAT-LONG.
 01 L-MAXX                 FLOAT-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-MAXZ                 FLOAT-LONG.
 01 L-NEAR                 FLOAT-LONG.
 01 L-FAR                  FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OX L-OY L-OZ L-DX L-DY L-DZ L-MINX L-MINY L-MINZ L-MAXX L-MAXY L-MAXZ L-NEAR L-FAR L-HIT.
     MOVE -1000000 TO L-NEAR
     MOVE 1000000 TO L-FAR
     MOVE 1 TO L-HIT
*>   One slab for each axis: the ray is inside the slab between its two crossing parameters; a ray parallel to the slab must start inside it.
     IF FUNCTION ABS(L-DX) < 0.0000001
         IF L-OX < L-MINX OR L-OX > L-MAXX
             MOVE 0 TO L-HIT
         END-IF
     ELSE
         COMPUTE WS-T1 = (L-MINX - L-OX) / L-DX
         COMPUTE WS-T2 = (L-MAXX - L-OX) / L-DX
         COMPUTE L-NEAR = FUNCTION MAX(L-NEAR, FUNCTION MIN(WS-T1, WS-T2))
         COMPUTE L-FAR = FUNCTION MIN(L-FAR, FUNCTION MAX(WS-T1, WS-T2))
     END-IF
     IF FUNCTION ABS(L-DY) < 0.0000001
         IF L-OY < L-MINY OR L-OY > L-MAXY
             MOVE 0 TO L-HIT
         END-IF
     ELSE
         COMPUTE WS-T1 = (L-MINY - L-OY) / L-DY
         COMPUTE WS-T2 = (L-MAXY - L-OY) / L-DY
         COMPUTE L-NEAR = FUNCTION MAX(L-NEAR, FUNCTION MIN(WS-T1, WS-T2))
         COMPUTE L-FAR = FUNCTION MIN(L-FAR, FUNCTION MAX(WS-T1, WS-T2))
     END-IF
     IF FUNCTION ABS(L-DZ) < 0.0000001
         IF L-OZ < L-MINZ OR L-OZ > L-MAXZ
             MOVE 0 TO L-HIT
         END-IF
     ELSE
         COMPUTE WS-T1 = (L-MINZ - L-OZ) / L-DZ
         COMPUTE WS-T2 = (L-MAXZ - L-OZ) / L-DZ
         COMPUTE L-NEAR = FUNCTION MAX(L-NEAR, FUNCTION MIN(WS-T1, WS-T2))
         COMPUTE L-FAR = FUNCTION MIN(L-FAR, FUNCTION MAX(WS-T1, WS-T2))
     END-IF
     IF L-NEAR > L-FAR
         MOVE 0 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM RANGED-RAY-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-STAB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CTOOLS.
 COPY RULES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DAMAGE10K           BINARY-LONG.
 01 WS-SPEED10K            BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-MINING              BINARY-LONG.
 01 WS-MODIFIER            BINARY-LONG.
 01 WS-HASTE               BINARY-LONG VALUE 0.
 01 WS-FATIGUE             BINARY-LONG VALUE 0.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-WEAKNESS            BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-TICKER              BINARY-LONG.
 01 WS-A                   BINARY-LONG VALUE 500.
 01 WS-SCALE               BINARY-LONG.
 01 WS-MINIMUM             BINARY-LONG VALUE 1000.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-BONUS               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-HASTE-ID            BINARY-LONG VALUE 2.
 01 WS-FATIGUE-ID          BINARY-LONG VALUE 3.
 01 WS-STRENGTH-ID         BINARY-LONG VALUE 4.
 01 WS-WEAKNESS-ID         BINARY-LONG VALUE 17.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EYE-HEIGHT          FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-NO-ANGLE            FLOAT-LONG VALUE 0.
 01 WS-MIN-REACH           FLOAT-LONG VALUE 2.0.
 01 WS-MAX-REACH           FLOAT-LONG.
 01 WS-MARGIN              FLOAT-LONG VALUE 0.125.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-VICTIM              BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 01 WS-EXHAUST             FLOAT-LONG VALUE 0.1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MILLI               BINARY-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-LUNGE               BINARY-LONG.
 01 WS-IMPULSE             BINARY-LONG.
 01 WS-LUNGE-EXH           BINARY-LONG.
 01 WS-LUNGE-DMG           BINARY-LONG.
 01 WS-RIDING              BINARY-LONG.
 01 WS-GLIDING             BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-IS-PLAYER           BINARY-LONG VALUE 1.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG VALUE 0.
 01 WS-VZ                  BINARY-LONG.
 01 WS-LUNGE-EXHAUST       FLOAT-LONG.
 01 WS-BROKE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "COMBAT-TS-CHECK" USING L-ROW
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     IF PL-STATE(L-ROW) NOT = PS-ALIVE OR PL-SLOT-COUNT(L-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, WS-SLOT) WS-KEY
     CALL "TOOL-SPEAR-STATS" USING WS-KEY WS-FOUND WS-DURABILITY WS-DAMAGE10K WS-SPEED10K WS-COOLDOWN WS-MINING
     IF WS-FOUND = 0
         GOBACK
     END-IF
*>   The attack strength (17 section 4.1) against the minimum attack charge 1.0.
     COMPUTE WS-MODIFIER = (WS-SPEED10K - 40000) / 10
     CALL "TOOL-ATTACK-SPEED" USING WS-MODIFIER WS-HASTE WS-FATIGUE WS-SPEED
     CALL "TOOL-ATTACK-DELAY" USING WS-SPEED WS-DELAY
     IF TS-LAST-ATTACK(L-ROW) = 0
         MOVE 1000 TO WS-TICKER
     ELSE
         COMPUTE WS-TICKER = CW-TICKS + 1 - TS-LAST-ATTACK(L-ROW)
     END-IF
     CALL "TOOL-ATTACK-SCALE" USING WS-TICKER WS-A WS-DELAY WS-SCALE
     CALL "TOOL-SPEAR-JAB" USING WS-SCALE WS-MINIMUM WS-ALLOWED
     IF WS-ALLOWED = 0
         GOBACK
     END-IF
*>   The attack damage: 1 + the material's bonus, with Strength and Weakness (as the melee rules do).
     CALL "EFFECT-LEVEL" USING L-ROW WS-STRENGTH-ID WS-STRENGTH WS-TICKS
     CALL "EFFECT-LEVEL" USING L-ROW WS-WEAKNESS-ID WS-WEAKNESS WS-TICKS
     COMPUTE WS-BONUS = WS-DAMAGE10K / 10 - 1000
     CALL "TOOL-ATTACK-ATTR" USING WS-BONUS WS-STRENGTH WS-WEAKNESS WS-BASE
     COMPUTE WS-POINTS ROUNDED = FUNCTION MAX(1, WS-BASE / 1000)
*>   The Lunge level of the spear as it was before the stab (a spear that breaks in the stab has still lunged).
     MOVE "minecraft:lunge" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING PL-SLOT-VAR(L-ROW, WS-SLOT) WS-LEVEL-KEY WS-LUNGE
     MOVE 4.5 TO WS-MAX-REACH
     IF PL-MODE(L-ROW) = 1
         MOVE 6.5 TO WS-MAX-REACH
     END-IF
*>   The look ray from the eye.
     MOVE PL-X(L-ROW) TO WS-EX
     CALL "POSE-EYE" USING L-ROW WS-EYE-HEIGHT
     COMPUTE WS-EY = PL-Y(L-ROW) + WS-EYE-HEIGHT
     MOVE PL-Z(L-ROW) TO WS-EZ
     CALL "RANGED-DIRECTION" USING PL-YAW(L-ROW) PL-PITCH(L-ROW) WS-NO-ANGLE WS-DX WS-DY WS-DZ
     MOVE 0 TO WS-HITS WS-BROKE
     MOVE PL-HELD(L-ROW) TO WS-HELD
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         MOVE 0 TO WS-VICTIM
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = PL-DIM(L-ROW) AND WS-E NOT = PL-ENTITY-ROW(L-ROW)
             IF EN-PLAYER(WS-E) > 0
                 IF PL-STATE(EN-PLAYER(WS-E)) = PS-ALIVE AND PL-MODE(EN-PLAYER(WS-E)) < 2 AND CS-PLAYER-COMBAT = 1
                     MOVE 1 TO WS-VICTIM
                 END-IF
             ELSE
                 IF EN-HEALTH(WS-E) > 0
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
                     IF WS-M > 0
                         MOVE 1 TO WS-VICTIM
                     END-IF
                 END-IF
             END-IF
         END-IF
         IF WS-VICTIM = 1
             COMPUTE WS-TYPE = EN-TYPE(WS-E) + 1
             COMPUTE WS-HALF = ET-WIDTH-MILLI(WS-TYPE) / 2000 + WS-MARGIN
             COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(WS-TYPE) / 1000
             MOVE EN-X(WS-E) TO WS-BX
             MOVE EN-Y(WS-E) TO WS-BY
             MOVE EN-Z(WS-E) TO WS-BZ
*>           A player's box stands at the player's own position.
             IF EN-PLAYER(WS-E) > 0
                 MOVE PL-X(EN-PLAYER(WS-E)) TO WS-BX
                 MOVE PL-Y(EN-PLAYER(WS-E)) TO WS-BY
                 MOVE PL-Z(EN-PLAYER(WS-E)) TO WS-BZ
             END-IF
             COMPUTE WS-MINX = WS-BX - WS-HALF
             COMPUTE WS-MAXX = WS-BX + WS-HALF
             COMPUTE WS-MINY = WS-BY - WS-MARGIN
             COMPUTE WS-MAXY = WS-BY + WS-HEIGHT + WS-MARGIN
             COMPUTE WS-MINZ = WS-BZ - WS-HALF
             COMPUTE WS-MAXZ = WS-BZ + WS-HALF
             CALL "RANGED-RAY-BOX" USING WS-EX WS-EY WS-EZ WS-DX WS-DY WS-DZ WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ
                 WS-NEAR WS-FAR WS-HIT
*>           The box must be met somewhere between the minimum and the maximum reach.
             IF WS-HIT = 1 AND WS-FAR >= WS-MIN-REACH AND WS-NEAR <= WS-MAX-REACH
                 ADD 1 TO WS-HITS
                 IF EN-PLAYER(WS-E) > 0
                     COMPUTE WS-MILLI = WS-POINTS * 1000
                     CALL "HEALTH-HURT" USING EN-PLAYER(WS-E) WS-MILLI WS-CAUSE PL-ENTITY-ID(L-ROW) L-ROW WS-RESULT
                 ELSE
                     CALL "HEALTH-MOB-DAMAGE" USING WS-E WS-POINTS WS-CAUSE L-ROW
                 END-IF
                 CALL "HUNGER-EXHAUST" USING L-ROW WS-EXHAUST
                 IF WS-BROKE = 0
                     CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) WS-HELD WS-ONE WS-BROKE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   The swing resets the attack strength.
     COMPUTE TS-LAST-ATTACK(L-ROW) = CW-TICKS + 1
*>   Lunge (6.3): after the stab, an impulse along the look vector without its vertical part, exhaustion and one more point of damage.
     IF WS-LUNGE > 0
         MOVE 0 TO WS-RIDING
         IF EN-VEHICLE(PL-ENTITY-ROW(L-ROW)) > 0
             MOVE 1 TO WS-RIDING
         END-IF
         MOVE 0 TO WS-GLIDING
         IF TS-GLIDE-TICKS(L-ROW) > 0
             MOVE 1 TO WS-GLIDING
         END-IF
         CALL "FLUID-TOUCHES-WATER" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-WATER
         MOVE PL-MODE(L-ROW) TO WS-CREATIVE
         MOVE PL-FOOD(L-ROW) TO WS-FOOD
         CALL "TOOL-LUNGE-ALLOWED" USING WS-RIDING WS-GLIDING WS-WATER WS-IS-PLAYER WS-CREATIVE WS-FOOD WS-OK
         IF WS-OK = 1
             CALL "TOOL-LUNGE" USING WS-LUNGE WS-IMPULSE WS-LUNGE-EXH WS-LUNGE-DMG
             COMPUTE WS-VX = WS-DX * WS-IMPULSE
             COMPUTE WS-VZ = WS-DZ * WS-IMPULSE
             CALL "COMBAT-MOTION-SEND" USING L-ROW WS-VX WS-VY WS-VZ
             COMPUTE WS-LUNGE-EXHAUST = WS-LUNGE-EXH / 1000
             CALL "HUNGER-EXHAUST" USING L-ROW WS-LUNGE-EXHAUST
             IF WS-BROKE = 0
                 CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) WS-HELD WS-LUNGE-DMG WS-BROKE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RANGED-STAB.
