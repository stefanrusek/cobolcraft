*> The drowned's trident (docs/protocol/20 section 4.5 with 44-8 sections 10 and 11; wrap I3, T2814/T2815).
*>   DROWNED-EQUIP-ROLL USING xoro state, hand (EN-HAND) inout: the drowned's default equipment (populateDefaultEquipmentSlots, which replaces the zombie one): nextFloat > 0.9 gives a weapon, then
*>     nextInt(16) < 10 a trident, else a fishing rod; the hand becomes 1000 + the item id (STDMOB-HAND-KEY reads it); with no weapon the hand is left alone. The floats are nextDouble draws.
*>     Called by STDMOB-FINALIZE for a drowned (the zombie weapon draw and the armour roll are not made).
*>   DROWNED-TRIDENT-STAND USING tracker row, stop inout: the approach part of RangedAttackGoal (18 section 4, radius 10.0) for a drowned that holds a trident and has a target: seeTime (EN-SWELL) counts
*>     the ticks of a line of sight (MOB-SEES, eyes to eyes; a change of sight resets it to 0 first, then it counts down by 1 without sight), and the drowned stands still (stop 1, facing the target in the
*>     mob step) when the target is within 10 blocks (squared distance at most 100) and seeTime is at least 5; otherwise it walks to the target as the generic chase does. Without a trident or a
*>     target seeTime is 0 and stop is left alone.
*>   DROWNED-TRIDENT-TICK USING tracker row: the trident attack goal (RangedAttackGoal speed 1.0, interval 40, range 10.0) of a drowned that holds a trident in the main hand (EN-HAND) and has a target
*>     (EN-TARGET, a player row). EN-SHOOT-TIME is the attackTime: 0 before the goal ran, then 40 on its first tick, counting down by 1 a tick; at 0 a line of sight to the target (MOB-SEES, eyes to eyes)
*>     throws the trident and starts the interval again (40), without one the goal starts the interval again on its next tick (vanilla: attackTime stays 0 and the next tick sets 40). Without a trident or
*>     a target the timer is 0. The approach (standing within 10 blocks) is DROWNED-TRIDENT-STAND, called before this one by the mob step. Not here: the sound.
*>   The throw (Drowned.performRangedAttack, 20 section 4.5): the trident (family 3 of ARROW-SPAWN-AS, owner the drowned, base damage 8.0) starts at the drowned's eye - 0.1 (feet + 1.74 - 0.1), the aim vector
*>     is the target's x and z minus the drowned's, the target's position at one third of its height minus the trident's y (the player: feet + 0.6), plus 0.2 x the horizontal distance on y; shot at speed 1.6
*>     with the inaccuracy 14 - 4 x difficulty id (each component of the normalised aim plus triangle(0, 0.0172275 x inaccuracy), as the pillager's arrow of mob-20-13.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-TRIDENT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-KEY                 PIC X(40).
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-EYE-Y               FLOAT-LONG.
 01 WS-TARGET-EYE          FLOAT-LONG.
 01 WS-INACC               FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 14.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG VALUE 3.
 01 WS-BASE                BINARY-LONG VALUE 8000.
 01 WS-OWNER               BINARY-LONG.
 01 WS-TRIDENT             BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-KEY NOT = "minecraft:trident" OR WS-P = 0
         MOVE 0 TO EN-SHOOT-TIME(L-ROW)
         GOBACK
     END-IF
     IF EN-SHOOT-TIME(L-ROW) = 0
         MOVE 40 TO EN-SHOOT-TIME(L-ROW)
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
     IF EN-SHOOT-TIME(L-ROW) > 0
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-EYE-Y = EN-Y(L-ROW) + 1.74
     MOVE EN-Z(L-ROW) TO WS-AZ
     COMPUTE WS-TARGET-EYE = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-EYE-Y WS-AZ PL-X(WS-P) WS-TARGET-EYE PL-Z(WS-P) WS-SEES
     IF WS-SEES = 0
         GOBACK
     END-IF
     MOVE 40 TO EN-SHOOT-TIME(L-ROW)
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-ID(L-ROW) TO WS-OWNER
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.74 - 0.1
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-TY = PL-Y(WS-P) + 0.6
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-DY = WS-TY - WS-AY + WS-H * 0.2
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WS-INACC = 0.0172275 * (14 - 4 * BW-DIFFICULTY)
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
     COMPUTE WS-VX = (WS-DX / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
     COMPUTE WS-VY = (WS-DY / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
     COMPUTE WS-VZ = (WS-DZ / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
     CALL "ARROW-SPAWN-AS" USING WS-FAMILY WS-DIM WS-AX WS-AY WS-AZ WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-TRIDENT
     GOBACK.
 END PROGRAM DROWNED-TRIDENT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-EQUIP-ROLL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-PICK                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-HAND.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     IF WS-D > 0.9
         CALL "XORO-NEXT-INT" USING L-STATE WS-SIXTEEN WS-PICK
         MOVE SPACES TO WS-KEY
         IF WS-PICK < 10
             MOVE "trident" TO WS-KEY
         ELSE
             MOVE "fishing_rod" TO WS-KEY
         END-IF
         CALL "RL-ITEM-ID-OF" USING WS-KEY WS-ITEM
         IF WS-ITEM >= 0
             COMPUTE L-HAND = 1000 + WS-ITEM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DROWNED-EQUIP-ROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-TRIDENT-STAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(40).
 01 WS-P                   BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STOP.
     CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-KEY NOT = "minecraft:trident" OR WS-P = 0
         MOVE 0 TO EN-SWELL(L-ROW)
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.74
     MOVE EN-Z(L-ROW) TO WS-AZ
     COMPUTE WS-TY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
     IF (WS-SEES = 1 AND EN-SWELL(L-ROW) <= 0) OR (WS-SEES = 0 AND EN-SWELL(L-ROW) > 0)
         MOVE 0 TO EN-SWELL(L-ROW)
     END-IF
     IF WS-SEES = 1
         ADD 1 TO EN-SWELL(L-ROW)
     ELSE
         SUBTRACT 1 FROM EN-SWELL(L-ROW)
     END-IF
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF WS-D2 <= 100 AND EN-SWELL(L-ROW) >= 5
         MOVE 1 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM DROWNED-TRIDENT-STAND.
