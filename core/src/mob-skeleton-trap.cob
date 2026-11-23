*> The skeleton horse trap (docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.6 "Skeleton horse trap" and the thunder spawn; 45-4 section 6.4; wrap I2 round 3, T52093).
*> A skeleton horse whose trap flag is set (WC-TRAP of WCSTATE.cpy; the thunder spawn of weather-44.cob sets it, SkeletonTrap in the NBT) runs SkeletonTrapGoal: with a living player within 10 blocks the flag
*> is cleared, the horse is tamed and an adult, a visual-only lightning bolt strikes it, a skeleton (finalised, an iron helmet when it rolled none) rides it, then 3 more skeleton horses with riding skeletons are made
*> (tamed, adult, persistent, invulnerable for 60 ticks: WC-INVUL-TICKS) with a random horizontal push triangle(0, 1.1485) on x and z. A trap horse that is not persistent is discarded once the flag has stood
*> 18000 ticks (WC-TRAP-TICKS). Gaps: the skeleton's main hand and head items are not enchanted by the difficulty (a mob's equipment holds no item components in this core), the baby metadata of a
*> horse that grows up is not resent, the engine's "spawn reason EVENT".
*>   SKELETON-HORSE-TICK USING row                  every tick of a skeleton horse: the invulnerable window counts down; with the trap flag the despawn count, the player check and the trap
*>   SKELETON-TRAP-FIRE USING row                   the trap springs at that horse
*>   SKELETON-TRAP-RIDER USING horse row            a finalised skeleton on the horse (an iron helmet if it has none)
*>   SKELETON-IMMUNE USING row, cause, flag out     1 while the invulnerable window runs, except for damage that bypasses invulnerability (out of the world, the kill command)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKELETON-HORSE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WC-ROW-OPEN" USING L-ROW
     IF WC-INVUL-TICKS(L-ROW) > 0
         SUBTRACT 1 FROM WC-INVUL-TICKS(L-ROW)
     END-IF
     IF WC-TRAP(L-ROW) = 1
         IF WC-TRAP-TICKS(L-ROW) >= 18000 AND EN-PERSISTENT(L-ROW) = 0
             CALL "ENTITY-REMOVE" USING L-ROW
             GOBACK
         END-IF
         ADD 1 TO WC-TRAP-TICKS(L-ROW)
*>       hasNearbyAlivePlayer: a living player of the dimension within 10 blocks.
         MOVE 0 TO WS-NEAR
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-D2 < 100
                     MOVE 1 TO WS-NEAR
                 END-IF
             END-IF
         END-PERFORM
         IF WS-NEAR = 1
             CALL "SKELETON-TRAP-FIRE" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SKELETON-HORSE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKELETON-TRAP-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:skeleton_horse".
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-VISUAL              BINARY-LONG VALUE 1.
 01 WS-BOLT                BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 7301.
 01 WS-BOUND               BINARY-LONG VALUE 10000.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-PUSH                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE 0 TO WC-TRAP(L-ROW) WC-TRAP-TICKS(L-ROW) EN-MOBAGE(L-ROW) EN-VARIANT(L-ROW)
     MOVE 1 TO EN-TAMED(L-ROW)
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "LIGHTNING-SPAWN" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-VISUAL WS-BOLT
     CALL "SKELETON-TRAP-RIDER" USING L-ROW
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-HORSE
         CALL "WC-ROW-OPEN" USING WS-HORSE
         MOVE 1 TO EN-TAMED(WS-HORSE) EN-PERSISTENT(WS-HORSE)
         MOVE 0 TO EN-MOBAGE(WS-HORSE) EN-VARIANT(WS-HORSE)
         MOVE 60 TO WC-INVUL-TICKS(WS-HORSE)
*>       The push of x and z: triangle(0, 1.1485) = 1.1485 x (r1 - r2) of two draws in [0, 1).
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D1
         ADD 1 TO WS-SALT
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D2
         ADD 1 TO WS-SALT
         COMPUTE WS-PUSH = 1.1485 * (WS-D1 - WS-D2) / 10000
         ADD WS-PUSH TO EN-VX(WS-HORSE)
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D1
         ADD 1 TO WS-SALT
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D2
         ADD 1 TO WS-SALT
         COMPUTE WS-PUSH = 1.1485 * (WS-D1 - WS-D2) / 10000
         ADD WS-PUSH TO EN-VZ(WS-HORSE)
         CALL "SKELETON-TRAP-RIDER" USING WS-HORSE
     END-PERFORM
     GOBACK.
 END PROGRAM SKELETON-TRAP-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKELETON-TRAP-RIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY XORO.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:skeleton".
 01 WS-TYPE                BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-HORSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-HORSE.
     MOVE EN-X(L-HORSE) TO WS-X
     MOVE EN-Y(L-HORSE) TO WS-Y
     MOVE EN-Z(L-HORSE) TO WS-Z
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     CALL "MOB-SPAWN" USING EN-DIM(L-HORSE) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-SKELETON
     COMPUTE WS-SEED = CW-TICKS * 31 + EN-ID(WS-SKELETON)
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-SKELETON
*>   An iron helmet (tier 4, one piece from the head) when the armour roll gave none.
     IF EN-EQUIP(WS-SKELETON) = 0
         MOVE 51 TO EN-EQUIP(WS-SKELETON)
     END-IF
     CALL "STDMOB-EQUIP-SEND" USING WS-SKELETON
     CALL "MOB-MOUNT" USING WS-SKELETON L-HORSE WS-MOUNTED
     GOBACK.
 END PROGRAM SKELETON-TRAP-RIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKELETON-IMMUNE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY RULES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-FLAG.
     MOVE 0 TO L-FLAG
     IF WC-ID(L-ROW) = EN-ID(L-ROW) AND WC-INVUL-TICKS(L-ROW) > 0 AND L-CAUSE NOT = CAUSE-VOID AND L-CAUSE NOT = CAUSE-COMMAND
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SKELETON-IMMUNE.
