*> Implementation test (002-lane-p49n; docs/protocol/18 sections 2.6, 2.8, 3.1, 3.3 and 4.4): the leftovers of the mob framework.
*> lastHurtByMob (2.8): a mob attacker is remembered for 100 ticks and forgotten earlier when it is dead; a zombie's hit on a villager sets it. The jump control (2.6 steps 1, 5 and 6,
*> 4.4): a request lasts one tick, a mob on the ground jumps (vertical velocity 0.42, 0.21 over a honey block) and waits noJumpDelay 10 ticks, in air it does not, an immobile mob (dead,
*> a sitting pet, a sleeping fox) never jumps, jumping in deep water adds 0.04, without a request the delay is 0. Water sensitivity (2.6 step 12): a snow golem in water or a blaze in rain
*> takes 1 each tick. pushEntities (3.3): overlapping mobs push each other along the line of their centres (0.05 x min(1 / sqrt(d), 1) of the unit vector), not when the centres are
*> within 0.01 or the boxes do not overlap.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-MOB18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY P49NSTATE.
 COPY CBLOCKS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-COW                 BINARY-LONG.
 01 WS-COW2                BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-VILLAGER            BINARY-LONG.
 01 WS-GOLEM               BINARY-LONG.
 01 WS-BLAZE               BINARY-LONG.
 01 WS-FOX                 BINARY-LONG.
 01 WS-WOLF                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-HONEY               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-IMM                 BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 2 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:honey_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-HONEY
     COMPUTE WS-X = WS-X + 8.5
     COMPUTE WS-Z = WS-Z + 8.5
     MOVE "minecraft:cow" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z WS-COW
     COMPUTE WS-X1 = WS-X + 0.3
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-COW2
     MOVE "minecraft:zombie" TO WS-KEY
     COMPUTE WS-Z1 = WS-Z + 6
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z1 WS-ZOMBIE

*>   2.8 lastHurtByMob: a zombie hurts the cow: it remembers the zombie 100 ticks.
     CALL "MOB-HURT-BY-MOB" USING WS-COW WS-ZOMBIE
     CALL "MOB-LAST-HURT-BY" USING WS-COW WS-ATTACKER
     MOVE "acceptance US15 18§2.8 A mob hit is remembered as lastHurtByMob" TO WS-CASE
     MOVE EN-ID(WS-ZOMBIE) TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-ATTACKER > 0
         MOVE EN-ID(WS-ATTACKER) TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 99
         CALL "MOB-LHBM-TICK" USING WS-COW
     END-PERFORM
     CALL "MOB-LAST-HURT-BY" USING WS-COW WS-ATTACKER
     MOVE "acceptance US15 18§2.8 It is still there after 99 ticks" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-ATTACKER > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-LHBM-TICK" USING WS-COW
     CALL "MOB-LAST-HURT-BY" USING WS-COW WS-ATTACKER
     MOVE "acceptance US15 18§2.8 and gone when 100 ticks have passed" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ATTACKER TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-HURT-BY-MOB" USING WS-COW WS-ZOMBIE
     MOVE 0 TO EN-HEALTH(WS-ZOMBIE)
     CALL "MOB-LHBM-TICK" USING WS-COW
     CALL "MOB-LAST-HURT-BY" USING WS-COW WS-ATTACKER
     MOVE "acceptance US15 18§2.8 A dead attacker is forgotten at once" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ATTACKER TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 20 TO EN-HEALTH(WS-ZOMBIE)
*>   A zombie's melee hit on a villager sets it (MOBVS-TICK).
     MOVE "minecraft:villager" TO WS-KEY
     COMPUTE WS-Z1 = WS-Z + 6.5
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z1 WS-VILLAGER
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ZOMBIE) WS-M
     MOVE 0 TO EN-PET-CD(WS-ZOMBIE) EN-FOE(WS-ZOMBIE)
     CALL "MOBVS-TICK" USING WS-ZOMBIE WS-M WS-HX WS-HZ WS-WALK
     CALL "MOB-LAST-HURT-BY" USING WS-VILLAGER WS-ATTACKER
     MOVE "acceptance US15 18§2.8 A zombie's hit on a villager is remembered by the villager" TO WS-CASE
     MOVE EN-ID(WS-ZOMBIE) TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-ATTACKER > 0
         MOVE EN-ID(WS-ATTACKER) TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-VILLAGER

*>   Jump control: on the ground a request makes a jump 0.42 and sets noJumpDelay 10.
     MOVE 1 TO EN-ON-GROUND(WS-COW)
     MOVE 0 TO EN-VY(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-COW) * 1000
     MOVE "acceptance US15 18§2.6 A jump from the ground gives vertical velocity 0.42" TO WS-CASE
     MOVE 420 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§2.6 noJumpDelay is 10" TO WS-CASE
     MOVE 10 TO WS-EXP
     MOVE PN-NOJUMP(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-VY(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     MOVE "acceptance US15 18§2.6 The next tick (delay 9) does not jump again" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VY(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 9 TO WS-EXP
     MOVE "acceptance US15 18§2.6 The delay counts down by 1 a tick" TO WS-CASE
     MOVE PN-NOJUMP(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "MOB-JUMP-REQUEST" USING WS-COW
         CALL "MOB-JUMP-TICK" USING WS-COW
     END-PERFORM
     MOVE "acceptance US15 18§2.6 Still no jump while the delay runs (1 left after 8 more ticks)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PN-NOJUMP(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-COW) * 1000
     MOVE "acceptance US15 18§2.6 When the delay has run out it jumps again" TO WS-CASE
     MOVE 420 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Without a request the delay is 0; a request lasts one tick (no second jump from the same request).
     CALL "MOB-JUMP-TICK" USING WS-COW
     MOVE "acceptance US15 18§2.6 Without a request noJumpDelay is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PN-NOJUMP(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-VY(WS-COW)
     CALL "MOB-JUMP-TICK" USING WS-COW
     MOVE "acceptance US15 18§4.4 The request of the tick before is spent: no jump" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VY(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   In the air there is no jump.
     MOVE 0 TO EN-ON-GROUND(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     MOVE "acceptance US15 18§2.6 In the air a request does not jump" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VY(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Over a honey block (jump factor 0.5) the power is 0.21.
     COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-COW))
     COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-COW))
     COMPUTE WS-FY = WS-BY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-HONEY
     MOVE 1 TO EN-ON-GROUND(WS-COW)
     MOVE 0 TO EN-VY(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-COW) * 1000
     MOVE "acceptance US15 18§2.6 Over a honey block the jump power is 0.42 x 0.5" TO WS-CASE
     MOVE 210 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Immobile: a dead mob, a sitting wolf.
     CALL "MOB-IMMOBILE" USING WS-COW WS-IMM
     MOVE "acceptance US15 18§2.6 A living cow is mobile" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-IMM TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "minecraft:wolf" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z WS-WOLF
     MOVE 1 TO EN-SIT(WS-WOLF)
     MOVE 1 TO EN-ON-GROUND(WS-WOLF)
     MOVE 0 TO EN-VY(WS-WOLF)
     CALL "MOB-IMMOBILE" USING WS-WOLF WS-IMM
     MOVE "acceptance US15 18§2.6 A sitting pet is immobile" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-IMM TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-JUMP-REQUEST" USING WS-WOLF
     CALL "MOB-JUMP-TICK" USING WS-WOLF
     MOVE "acceptance US15 18§2.6 An immobile mob does not jump and its request is dropped" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-WOLF) * 1000 + PN-JUMP(WS-WOLF)
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-SIT(WS-WOLF)
     MOVE 0 TO EN-HEALTH(WS-WOLF)
     CALL "MOB-IMMOBILE" USING WS-WOLF WS-IMM
     MOVE "acceptance US15 18§2.6 A dying mob is immobile" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-IMM TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-WOLF
     MOVE "minecraft:fox" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z WS-FOX
     MOVE 32 TO EN-FOX-FLAGS(WS-FOX)
     CALL "MOB-IMMOBILE" USING WS-FOX WS-IMM
     MOVE "acceptance US15 18§2.6 A sleeping fox is immobile" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-IMM TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FOX
*>   Jumping in deep water: +0.04 (the water is at the cell and 0.4 above the feet).
     COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-COW))
     COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-COW))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     MOVE 0 TO EN-ON-GROUND(WS-COW)
     MOVE 0 TO EN-VY(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-COW) * 1000
     MOVE "acceptance US15 18§2.6 Jumping in deep water adds 0.04 to the vertical velocity" TO WS-CASE
     MOVE 40 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR

*>   2.6 step 12: a snow golem standing in water takes 1 a tick (it has 4); in the open air nothing.
     MOVE "minecraft:snow_golem" TO WS-KEY
     COMPUTE WS-X1 = WS-X - 4
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-GOLEM
     CALL "STDMOB-WATER-HURT" USING WS-GOLEM
     MOVE "acceptance US15 18§2.6 A snow golem on dry ground takes no damage" TO WS-CASE
     MOVE EN-HEALTH(WS-GOLEM) TO WS-HEALTH
     MOVE WS-HEALTH TO WS-EXP
     MOVE EN-HEALTH(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-GOLEM))
     COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-GOLEM))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     CALL "STDMOB-WATER-HURT" USING WS-GOLEM
     MOVE "acceptance US15 18§2.6 In water the snow golem takes 1" TO WS-CASE
     COMPUTE WS-EXP = WS-HEALTH - 1
     MOVE EN-HEALTH(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR
     MOVE "minecraft:cow" TO WS-KEY
     COMPUTE WS-X1 = WS-X - 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH
     CALL "STDMOB-WATER-HURT" USING WS-COW
     MOVE "acceptance US15 18§2.6 A cow is not water-sensitive" TO WS-CASE
     MOVE WS-HEALTH TO WS-EXP
     MOVE EN-HEALTH(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR

*>   3.3 pushEntities: two cows 0.3 apart along x: each pushes the other by 0.05 x unit / sqrt(0.3) (0.0274); a ring that is apart, or centres 0.005 apart, does not push.
     MOVE 0 TO EN-VX(WS-COW) EN-VZ(WS-COW) EN-VX(WS-COW2) EN-VZ(WS-COW2)
     CALL "MOB-PUSH-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VX(WS-COW) * 10000
     MOVE "acceptance US15 18§3.3 The pushing cow goes west by 0.0274 (x 10000 = -274)" TO WS-CASE
     MOVE -274 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-MILLI ROUNDED = EN-VX(WS-COW2) * 10000
     MOVE "acceptance US15 18§3.3 The pushed cow goes east by 0.0274" TO WS-CASE
     MOVE 274 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§3.3 There is no push along z" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-MILLI ROUNDED = EN-VZ(WS-COW) * 10000 + EN-VZ(WS-COW2) * 10000
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-VX(WS-COW) EN-VX(WS-COW2)
     COMPUTE EN-X(WS-COW2) = EN-X(WS-COW) + 0.005
     CALL "MOB-PUSH-TICK" USING WS-COW
     MOVE "acceptance US15 18§3.3 Centres 0.005 apart (d below 0.01): no push" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-MILLI ROUNDED = EN-VX(WS-COW) * 10000 + EN-VX(WS-COW2) * 10000
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE EN-X(WS-COW2) = EN-X(WS-COW) + 2
     CALL "MOB-PUSH-TICK" USING WS-COW
     MOVE "acceptance US15 18§3.3 Cows 2 blocks apart do not overlap: no push" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-MILLI ROUNDED = EN-VX(WS-COW) * 10000 + EN-VX(WS-COW2) * 10000
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-P49N-MOB18.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     IF L-KEY = "minecraft:sulfur_cube"
         CALL "SULFUR-CUBE-INIT" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.

 COPY CORETEST.
 COPY MOBSPTEST.
