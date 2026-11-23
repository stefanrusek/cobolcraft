*> Live redstone, the shot projectiles of the dispenser (docs/protocol/30-redstone-4 section 4.1, 44 part x2 continuation), reached from RL-DISP-MORE: the fire charge, the wind charge, the firework rocket and the
*> splash and lingering potions (ProjectileDispenseBehavior). Each is made at a position along the dispenser's facing step and shot with Projectile.shoot (the unit step plus a triangle of 0.0172275 x the
*> uncertainty on each axis, times the power): the fire charge and the wind charge from the centre of the front cell (centre + 1.0 x step) with power 1.0 and uncertainty 6.6666665, the firework rocket from
*> centre + 0.5000099999997474 x step with power 0.5 and uncertainty 1.0 (shot at an angle: no acceleration, PJ-I5 1; a flight duration of 1 and no stars, the slots carry no components), the potions from the default
*> position (centre + 0.7 x step and 0.1 above) with power 1.375 and uncertainty 3.0, carrying the contents of the slot (the variant, POTION-LOAD; the lingering one at scale 250). The charges draw their own vector
*> first (6 draws of the level random, no lasting effect: the shot velocity replaces it), here as a discarded jitter. The item is spent (consumed 3 the launch sound 1002, 4 the fire charge 1018, 5 the wind
*> charge 1051, 6 the firework rocket 1004: RL-DISP-HOOK maps them).
*> Not done: the sounds themselves (FR-043; the level events are sent), the stack of a fire charge as the fireball's item, the potion contents of a tipped arrow.
*> Entry points:
*>   RL-DISP-SHOT USING dim, front x, y, z, facing, item bare key (PIC X(48)), slot variant, handled out, consumed out    handled 1 when the entity was made

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-SHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-KIND                BINARY-LONG VALUE 0.
 01 LS-CODE                BINARY-LONG.
 01 LS-OFFSET              FLOAT-LONG.
 01 LS-LIFT                FLOAT-LONG.
 01 LS-POWER               FLOAT-LONG.
 01 LS-UNCERTAIN           FLOAT-LONG.
 01 LS-ONE                 FLOAT-LONG VALUE 1.0.
 01 LS-FX                  FLOAT-LONG.
 01 LS-FY                  FLOAT-LONG.
 01 LS-FZ                  FLOAT-LONG.
 01 LS-VX                  FLOAT-LONG.
 01 LS-VY                  FLOAT-LONG.
 01 LS-VZ                  FLOAT-LONG.
 01 LS-SX                  FLOAT-LONG.
 01 LS-SY                  FLOAT-LONG.
 01 LS-SZ                  FLOAT-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-SLOT                BINARY-LONG.
 01 LS-PJ                  BINARY-LONG.
 01 LS-NONE                BINARY-LONG VALUE 0.
 01 LS-OWNER               BINARY-LONG VALUE 0.
 01 LS-STARS               BINARY-LONG VALUE 0.
 01 LS-ATTACHED            BINARY-LONG VALUE 0.
 01 LS-BREEZE              BINARY-LONG VALUE 0.
 01 LS-LINGER              BINARY-LONG.
 01 LS-DURATION            BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-BARE                 PIC X(48).
 01 L-VAR                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-BARE L-VAR L-HANDLED L-CONSUMED.
     MOVE 0 TO L-HANDLED L-CONSUMED
     CALL "RS1-STEP" USING L-FACING LS-DX LS-DY LS-DZ
*>   the table of 4.1: position function (offset along the step, lift), power, uncertainty and the sound event
     EVALUATE TRUE
         WHEN L-BARE = "fire_charge"
             MOVE 1 TO LS-KIND
             MOVE 4 TO LS-CODE
             MOVE 1.0 TO LS-OFFSET
             MOVE 0 TO LS-LIFT
             MOVE 1.0 TO LS-POWER
             MOVE 6.6666665 TO LS-UNCERTAIN
         WHEN L-BARE = "wind_charge"
             MOVE 2 TO LS-KIND
             MOVE 5 TO LS-CODE
             MOVE 1.0 TO LS-OFFSET
             MOVE 0 TO LS-LIFT
             MOVE 1.0 TO LS-POWER
             MOVE 6.6666665 TO LS-UNCERTAIN
         WHEN L-BARE = "firework_rocket"
             MOVE 3 TO LS-KIND
             MOVE 6 TO LS-CODE
             MOVE 0.5000099999997474 TO LS-OFFSET
             MOVE 0 TO LS-LIFT
             MOVE 0.5 TO LS-POWER
             MOVE 1.0 TO LS-UNCERTAIN
         WHEN L-BARE = "splash_potion"
             MOVE 4 TO LS-KIND
         WHEN L-BARE = "lingering_potion"
             MOVE 5 TO LS-KIND
     END-EVALUATE
     IF LS-KIND >= 4
         MOVE 3 TO LS-CODE
         MOVE 0.7 TO LS-OFFSET
         MOVE 0.1 TO LS-LIFT
         MOVE 1.375 TO LS-POWER
         MOVE 3.0 TO LS-UNCERTAIN
     END-IF
*>   the dispenser's centre, then along the facing
     COMPUTE LS-FX = L-X - LS-DX + 0.5 + LS-OFFSET * LS-DX
     COMPUTE LS-FY = L-Y - LS-DY + 0.5 + LS-OFFSET * LS-DY + LS-LIFT
     COMPUTE LS-FZ = L-Z - LS-DZ + 0.5 + LS-OFFSET * LS-DZ
     MOVE LS-DX TO LS-VX
     MOVE LS-DY TO LS-VY
     MOVE LS-DZ TO LS-VZ
*>   the item's own vector of the two charges: three triangles of the level random, no lasting effect
     IF LS-KIND <= 2
         MOVE LS-DX TO LS-SX
         MOVE LS-DY TO LS-SY
         MOVE LS-DZ TO LS-SZ
         CALL "THROWN-JITTER" USING LS-SX LS-SY LS-SZ LS-ONE LS-UNCERTAIN
     END-IF
     CALL "THROWN-JITTER" USING LS-VX LS-VY LS-VZ LS-POWER LS-UNCERTAIN
     MOVE 0 TO LS-ROW
     EVALUATE LS-KIND
         WHEN 1
*>           the small fireball (it is started along its shot direction, then given the shot velocity)
             MOVE 2 TO LS-PJ
             CALL "PROJ-SPAWN" USING LS-PJ L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-NONE LS-OWNER LS-ROW
             IF LS-ROW > 0
                 MOVE LS-VX TO EN-VX(LS-ROW)
                 MOVE LS-VY TO EN-VY(LS-ROW)
                 MOVE LS-VZ TO EN-VZ(LS-ROW)
             END-IF
         WHEN 2
             CALL "WIND-SPAWN" USING LS-BREEZE L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-OWNER LS-ROW
         WHEN 3
             CALL "FIREWORK-SPAWN" USING L-DIM LS-FX LS-FY LS-FZ LS-DURATION LS-STARS LS-ATTACHED LS-OWNER LS-ROW
             IF LS-ROW > 0
                 MOVE LS-VX TO EN-VX(LS-ROW)
                 MOVE LS-VY TO EN-VY(LS-ROW)
                 MOVE LS-VZ TO EN-VZ(LS-ROW)
                 CALL "PJ-FIND" USING EN-ID(LS-ROW) LS-SLOT
                 MOVE 1 TO PJ-I5(LS-SLOT)
             END-IF
         WHEN 4
         WHEN 5
             COMPUTE LS-LINGER = LS-KIND - 4
             CALL "POTION-SPAWN" USING LS-LINGER L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-OWNER LS-ROW
             IF LS-ROW > 0
                 CALL "POTION-LOAD" USING LS-ROW L-VAR LS-LINGER
             END-IF
     END-EVALUATE
     IF LS-ROW > 0
         MOVE 1 TO L-HANDLED
         MOVE LS-CODE TO L-CONSUMED
     END-IF
     GOBACK.
 END PROGRAM RL-DISP-SHOT.
