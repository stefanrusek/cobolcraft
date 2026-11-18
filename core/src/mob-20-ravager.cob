*> The ravager's timers, stun and roar (docs/protocol/20 section 13.6; lane 002-lane-mobsb5, T8909). State: RV-ENTRY of EVKSTATE.cpy.
*>   EVK-RV-FIND USING entity id, create, slot out
*>   RAVAGER-ATTACKED USING ravager row           a hit: AttackTick 10 (called with entity event 4)
*>   RAVAGER-STUN USING ravager row               stunned for 40 ticks (a shield blocked its hit; entity event 39 to the viewers)
*>   RAVAGER-STEP USING ravager row, immobile out one tick: the timers, the roar (countdown 20, the blast at 10), immobile 1 while stunned, roaring or within 10 ticks of a hit
*> The roar: every living entity within the box inflated by 4 that is no ravager takes 6 mob-attack damage unless it is an illager, and every one that is no player is thrown
*> (push 4 x dx / n, 0.2, 4 x dz / n with n the squared horizontal distance, at least 0.001); players get entity event 69 (the client applies the throw).
*> Gaps: the speed lerp 0.1 towards 0.35 and leaf destruction, stun particles, the box is
*> taken as 4.975 blocks horizontally and -4 to +6.2 vertically from the feet, the roar sound.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-RV-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RV-MAX OR L-SLOT > 0
         IF RV-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RV-MAX OR L-SLOT > 0
             IF RV-ID(WS-I) = 0
                 INITIALIZE RV-ENTRY(WS-I)
                 MOVE L-ID TO RV-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EVK-RV-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-ATTACKED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "EVK-RV-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         MOVE 10 TO RV-ATTACK(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM RAVAGER-ATTACKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-STUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY PROTO.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-EVENT                BINARY-LONG VALUE 39.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "EVK-RV-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         MOVE 40 TO RV-STUN(WS-SLOT)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM RAVAGER-STUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-BLOCKED.
*> USING mob row, blocking player row (called by HEALTH-HURT when a raised shield blocked a mob's hit, Ravager.blockedByShield, 20 section 13.6): only a ravager with RoarTick 0 reacts:
*> with probability 0.5 it is stunned for 40 ticks (RAVAGER-STUN; the document does not give the push of the blocker, not modelled), else strongKnockback on the blocker: push
*> (dx / n x 4, 0.2, dz / n x 4) with n = max(dx squared + dz squared, 0.001), sent to the player as Set Entity Motion.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-KEY                  PIC X(24).
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-SALT                 BINARY-LONG VALUE 107.
 01 WS-BOUND                BINARY-LONG VALUE 2.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-NN                   FLOAT-LONG.
 01 WS-VX                   BINARY-LONG.
 01 WS-VY                   BINARY-LONG VALUE 200.
 01 WS-VZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PLAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY NOT = "ravager"
         GOBACK
     END-IF
     CALL "EVK-RV-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0 OR RV-ROAR(WS-SLOT) > 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     IF WS-DRAW = 0
         CALL "RAVAGER-STUN" USING L-ROW
     ELSE
         COMPUTE WS-DX = PL-X(L-PLAYER) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(L-PLAYER) - EN-Z(L-ROW)
         COMPUTE WS-NN = FUNCTION MAX(WS-DX * WS-DX + WS-DZ * WS-DZ, 0.001)
         COMPUTE WS-VX = WS-DX / WS-NN * 4000
         COMPUTE WS-VZ = WS-DZ / WS-NN * 4000
         CALL "COMBAT-MOTION-SEND" USING L-PLAYER WS-VX WS-VY WS-VZ
     END-IF
     GOBACK.
 END PROGRAM RAVAGER-BLOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-ROAR.
*> USING ravager row: the blast of the roar.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 COPY PROTO.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-ILLAGER              BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-NN                   FLOAT-LONG.
 01 WS-DAMAGE               BINARY-LONG VALUE 6.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-EVENT                BINARY-LONG VALUE 69.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND WS-N NOT = L-ROW
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             IF WS-S > 0
                 COMPUTE WS-DX = EN-X(WS-N) - EN-X(L-ROW)
                 COMPUTE WS-DY = EN-Y(WS-N) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-N) - EN-Z(L-ROW)
                 IF SM-KEY(WS-S) NOT = "ravager" AND FUNCTION ABS(WS-DX) <= 4.975 AND FUNCTION ABS(WS-DZ) <= 4.975
                         AND WS-DY >= -4 AND WS-DY <= 6.2
                     MOVE 0 TO WS-ILLAGER
                     IF SM-KEY(WS-S) = "evoker" OR "vindicator" OR "pillager" OR "illusioner"
                         MOVE 1 TO WS-ILLAGER
                     END-IF
                     IF WS-ILLAGER = 0
                         CALL "HEALTH-MOB-DAMAGE" USING WS-N WS-DAMAGE CAUSE-MOB WS-NONE
                     END-IF
                     COMPUTE WS-NN = FUNCTION MAX(WS-DX * WS-DX + WS-DZ * WS-DZ, 0.001)
                     COMPUTE EN-VX(WS-N) = EN-VX(WS-N) + WS-DX / WS-NN * 4
                     COMPUTE EN-VY(WS-N) = EN-VY(WS-N) + 0.2
                     COMPUTE EN-VZ(WS-N) = EN-VZ(WS-N) + WS-DZ / WS-NN * 4
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             IF FUNCTION ABS(WS-DX) <= 4.975 AND FUNCTION ABS(WS-DZ) <= 4.975 AND WS-DY >= -4 AND WS-DY <= 6.2
                 CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RAVAGER-ROAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-STILL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STILL.
     MOVE 0 TO L-STILL
     CALL "EVK-RV-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF RV-SPEED(WS-SLOT) = 0
         MOVE 300000 TO RV-SPEED(WS-SLOT)
     END-IF
*>   Leaves in its way are destroyed after a horizontal collision (13.6).
     CALL "RAVAGER-LEAVES" USING L-ROW
*>   The movement speed attribute lerps by 0.1 towards 0.35 with a target, else 0.3 (13.6).
     IF EN-TARGET(L-ROW) > 0
         COMPUTE RV-SPEED(WS-SLOT) = RV-SPEED(WS-SLOT) + (350000 - RV-SPEED(WS-SLOT)) / 10
     ELSE
         COMPUTE RV-SPEED(WS-SLOT) = RV-SPEED(WS-SLOT) + (300000 - RV-SPEED(WS-SLOT)) / 10
     END-IF
     IF RV-ATTACK(WS-SLOT) > 0
         SUBTRACT 1 FROM RV-ATTACK(WS-SLOT)
     END-IF
     IF RV-ROAR(WS-SLOT) > 0
         SUBTRACT 1 FROM RV-ROAR(WS-SLOT)
         IF RV-ROAR(WS-SLOT) = 10
             CALL "RAVAGER-ROAR" USING L-ROW
         END-IF
     END-IF
     IF RV-STUN(WS-SLOT) > 0
         SUBTRACT 1 FROM RV-STUN(WS-SLOT)
         IF RV-STUN(WS-SLOT) = 0
             MOVE 20 TO RV-ROAR(WS-SLOT)
         END-IF
     END-IF
     IF RV-STUN(WS-SLOT) > 0 OR RV-ATTACK(WS-SLOT) > 0 OR RV-ROAR(WS-SLOT) > 0
         MOVE 1 TO L-STILL
     END-IF
     GOBACK.
 END PROGRAM RAVAGER-STEP.
