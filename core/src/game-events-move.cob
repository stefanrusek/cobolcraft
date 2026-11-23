*> Movement game events (lane 002-lane-p49y; docs/protocol/30-redstone-8 section 14.1): the emission pass of Entity.move for every tracked entity that moves. One entry point:
*>   GAME-EVENT-MOVED USING tracker row, new x, y, z (FLOAT-LONG), on-ground flag (BINARY-LONG): called by ENTITY-MOVE before it stores the new position (EN-X to EN-Z still hold the old one, EN-ON-GROUND the old flag).
*>     The collided movement m is the displacement from the old to the new position (the core does not replay a player's packet through the collision step: the accepted displacement is the movement, 30-8 14.1.1).
*>     A displacement over 8 blocks is a teleport (a command, a pet's jump, a respawn), not a step: nothing is posted and no counter changes. A spectator (noPhysics), a passenger (a rider, a mob riding a mob) and
*>     an entity of emission NONE (item, arrow, trident, experience orb, tnt, falling block, end crystal, shulker, fishing bobber) post nothing and keep their counters; a player who is flying, or on the ground with the
*>     shift key down, has emission NONE too (14.1.2). The pass, in the order of Entity.move for a mob (a player's packet handler runs the fall handling after the emission pass, 14.1.1):
*>       1. splash (14.1.8): the entity enters water (its box touches water now and did not at its previous pass; the first pass of a row never splashes); source the entity, position its own; fallDistance resets
*>          to 0 while in water.
*>       2. fall handling (14.1.7): while not in water a downward movement adds its length to fallDistance; on the ground with fallDistance > 0 hit_ground is posted (source the entity, affected state the supporting
*>          block's) and fallDistance resets. A player's upward movement resets it (the packet handler's rule). Bats, allays, bees, ghasts, parrots, phantoms and boats never post hit_ground.
*>       3. bounce (14.1.9): landing (on the ground, moved down more than the gravity 0.08 in one pass) on a slime block, a bed or a shelf mushroom, without the shift key, and not on a block of the tag
*>          suppresses_bounce (Open question 7, the reflected speed, is not modelled: only the event).
*>       4. emission pass (14.1.4): moveDist grows by 0.6 x the horizontal length (the whole length on a climbable block), flyDist by 0.6 x the whole length (floats); when moveDist > nextStep and the supporting
*>          block is not air the step is attempted (on the ground, on a climbable state, crouching with no vertical movement, or a minecart on rails; not swimming): step with the supporting block's state, nextStep =
*>          the next integer (turtle +0.15, warden +0.55, strider +0.6); with no step in water swim is posted instead. With air below, flap is posted by the entities that flap (bat, allay, bee, phantom, vex).
*>     Open questions (30-8 section 15), the simplest reading: item 17 (packet handler against the self-simulation pass): a player's flag is the packet's own on-ground flag, no extra pass with m = 0 is run; item 7:
*>     the reflected vertical speed is not computed; the supporting block is the cell holding (x, y - 1e-5, z), the cell below when that is air and the one under it is not (fences, walls), where the legacy
*>     cell is the same cell; else the cell holding (x, y - 0.2, z).
*>   GAME-EVENT-ROW-KEY USING tracker row, key out (PIC X(48)): the entity type key of the row as the core's tables hold it (without the namespace; "player" for a player).
*>   GAME-EVENT-IS-AIR USING block state, flag out: the state is air, cave air or void air (state 0 and the two other air blocks; a state not in the table counts as air).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-ROW-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-ROW L-KEY.
     MOVE SPACES TO L-KEY
     IF EN-PLAYER(L-ROW) > 0
         MOVE "player" TO L-KEY
         GOBACK
     END-IF
     IF EN-TYPE(L-ROW) >= 0 AND EN-TYPE(L-ROW) < ET-COUNT
         MOVE ET-KEY(EN-TYPE(L-ROW) + 1) TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-ROW-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-IS-AIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLAG.
     MOVE 1 TO L-FLAG
     IF L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY
         IF WS-KEY NOT = "air" AND WS-KEY NOT = "cave_air" AND WS-KEY NOT = "void_air"
             MOVE 0 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-IS-AIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-CLIMBABLE.
*> USING block state, flag out: the state is in the block tag climbable or is powder snow (Entity.isStateClimbable).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:climbable".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK L-FLAG
         MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY
         IF WS-KEY = "powder_snow"
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-CLIMBABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-NEXT-STEP.
*> USING context: Entity.nextStep(): the next integer above moveDist ((float)((int)moveDist + 1)); a turtle moveDist + 0.15, a warden + 0.55, a strider + 0.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY GEMOVE.
 PROCEDURE DIVISION USING MV-CTX.
     EVALUATE MV-KEY
         WHEN "turtle"
             COMPUTE EN-NEXT-STEP(MV-ROW) = EN-MOVE-DIST(MV-ROW) + 0.15
         WHEN "warden"
             COMPUTE EN-NEXT-STEP(MV-ROW) = EN-MOVE-DIST(MV-ROW) + 0.55
         WHEN "strider"
             COMPUTE EN-NEXT-STEP(MV-ROW) = EN-MOVE-DIST(MV-ROW) + 0.6
         WHEN OTHER
             COMPUTE EN-NEXT-STEP(MV-ROW) = FUNCTION INTEGER-PART(EN-MOVE-DIST(MV-ROW)) + 1
     END-EVALUATE
     GOBACK.
 END PROGRAM GAME-EVENT-NEXT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-STEP-TRY.
*> USING context, state, post flag, success out: Entity.stepAttempt: fails on air; succeeds when (the entity is on the ground, or the state is climbable, or it is crouching with no vertical movement, or it is a minecart
*> (on rails)) and it is not swimming; on success step is posted at the entity's own position when the post flag is 1, with the state as the affected state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EV-STEP             PIC X(32) VALUE "step".
 01 WS-AIR                 BINARY-LONG.
 01 WS-CLIMB               BINARY-LONG.
 01 WS-RAILS               BINARY-LONG.
 LINKAGE SECTION.
 COPY GEMOVE.
 01 L-STATE                BINARY-LONG.
 01 L-POST                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING MV-CTX L-STATE L-POST L-OK.
     MOVE 0 TO L-OK
     CALL "GAME-EVENT-IS-AIR" USING L-STATE WS-AIR
     IF WS-AIR = 1
         GOBACK
     END-IF
     CALL "GAME-EVENT-CLIMBABLE" USING L-STATE WS-CLIMB
     MOVE 0 TO WS-RAILS
     IF MV-KEY = "minecart" OR MV-KEY = "chest_minecart" OR MV-KEY = "furnace_minecart" OR MV-KEY = "tnt_minecart"
             OR MV-KEY = "hopper_minecart" OR MV-KEY = "spawner_minecart" OR MV-KEY = "command_block_minecart"
         MOVE 1 TO WS-RAILS
     END-IF
     IF (MV-ON-GROUND = 1 OR WS-CLIMB = 1 OR (MV-CROUCH = 1 AND MV-DY = 0) OR WS-RAILS = 1) AND MV-SWIMMING = 0
         MOVE 1 TO L-OK
         IF L-POST = 1
             CALL "GAME-EVENT" USING MV-DIM MV-X MV-Y MV-Z WS-EV-STEP MV-ROW L-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-STEP-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-FLAP.
*> USING context: processFlappingMovement: isFlapping() of the entities that flap, then flap at the entity's own position (30-8 14.1.6): a bat on every tickCount that is a multiple of 10 while it is not resting
*> (EN-PH-PHASE 0; a resting bat hangs and does not flap), an allay off the ground, a bee off the ground on every second tick, a phantom when (id mod 25 + tickCount) mod 25 = 0 (the unique flap offset is the entity id
*> mod 25), a vex every fourth tick. The chicken and parrot (flyDist against nextFlap) and the dragon's phase are not here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EV-FLAP             PIC X(32) VALUE "flap".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-TICK                BINARY-DOUBLE.
 01 WS-FLAPS               BINARY-LONG.
 LINKAGE SECTION.
 COPY GEMOVE.
 PROCEDURE DIVISION USING MV-CTX.
     COMPUTE WS-TICK = CW-TICKS - EN-BORN(MV-ROW)
     MOVE 0 TO WS-FLAPS
     EVALUATE MV-KEY
         WHEN "bat"
             IF EN-PH-PHASE(MV-ROW) = 0 AND FUNCTION MOD(WS-TICK, 10) = 0
                 MOVE 1 TO WS-FLAPS
             END-IF
         WHEN "allay"
             IF MV-ON-GROUND = 0
                 MOVE 1 TO WS-FLAPS
             END-IF
         WHEN "bee"
             IF MV-ON-GROUND = 0 AND FUNCTION MOD(WS-TICK, 2) = 0
                 MOVE 1 TO WS-FLAPS
             END-IF
         WHEN "phantom"
             IF FUNCTION MOD(FUNCTION MOD(EN-ID(MV-ROW), 25) + WS-TICK, 25) = 0
                 MOVE 1 TO WS-FLAPS
             END-IF
         WHEN "vex"
             IF FUNCTION MOD(WS-TICK, 4) = 0
                 MOVE 1 TO WS-FLAPS
             END-IF
     END-EVALUATE
     IF WS-FLAPS = 1
         CALL "GAME-EVENT" USING MV-DIM MV-X MV-Y MV-Z WS-EV-FLAP MV-ROW WS-NO-STATE
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-FLAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-PASS.
*> USING context: one emission pass (30-8 14.1.4), see the head of the file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EV-SWIM             PIC X(32) VALUE "swim".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-SCALE               FLOAT-LONG VALUE 0.6000000238418579.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-V3                  FLOAT-SHORT.
 01 WS-VH                  FLOAT-SHORT.
 01 WS-CLIMB1              BINARY-LONG.
 01 WS-AIR1                BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-POST                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY GEMOVE.
 PROCEDURE DIVISION USING MV-CTX.
     COMPUTE WS-LEN = FUNCTION SQRT(MV-DX * MV-DX + MV-DY * MV-DY + MV-DZ * MV-DZ)
     COMPUTE WS-H = FUNCTION SQRT(MV-DX * MV-DX + MV-DZ * MV-DZ)
     COMPUTE WS-V3 = WS-LEN * WS-SCALE
     COMPUTE WS-VH = WS-H * WS-SCALE
     MOVE 0 TO WS-CLIMB1
     IF MV-DY NOT = 0
         CALL "GAME-EVENT-CLIMBABLE" USING MV-S1 WS-CLIMB1
     END-IF
     IF WS-CLIMB1 = 1
         COMPUTE EN-MOVE-DIST(MV-ROW) = EN-MOVE-DIST(MV-ROW) + WS-V3
     ELSE
         COMPUTE EN-MOVE-DIST(MV-ROW) = EN-MOVE-DIST(MV-ROW) + WS-VH
     END-IF
     COMPUTE EN-FLY-DIST(MV-ROW) = EN-FLY-DIST(MV-ROW) + WS-V3
     IF EN-NEXT-STEP(MV-ROW) = 0
         MOVE 1 TO EN-NEXT-STEP(MV-ROW)
     END-IF
     CALL "GAME-EVENT-IS-AIR" USING MV-S1 WS-AIR1
     IF EN-MOVE-DIST(MV-ROW) > EN-NEXT-STEP(MV-ROW) AND WS-AIR1 = 0
         MOVE MV-SAME TO WS-POST
         CALL "GAME-EVENT-STEP-TRY" USING MV-CTX MV-S0 WS-POST WS-R1
         MOVE 0 TO WS-R2
         IF MV-SAME = 0
             CALL "GAME-EVENT-STEP-TRY" USING MV-CTX MV-S1 WS-ONE WS-R2
         END-IF
         IF WS-R1 = 1 OR WS-R2 = 1
             CALL "GAME-EVENT-NEXT-STEP" USING MV-CTX
         ELSE
             IF MV-WET = 1
                 CALL "GAME-EVENT-NEXT-STEP" USING MV-CTX
                 CALL "GAME-EVENT" USING MV-DIM MV-X MV-Y MV-Z WS-EV-SWIM MV-ROW WS-NO-STATE
             END-IF
         END-IF
     END-IF
     IF WS-AIR1 = 1
         CALL "GAME-EVENT-FLAP" USING MV-CTX
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-PASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-FALL.
*> USING context, supporting state: the fall handling and the bounce (30-8 14.1.7 and 14.1.9), see the head of the file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-SUPPRESSES          PIC X(112) VALUE "minecraft:suppresses_bounce".
 01 WS-EV-HIT              PIC X(32) VALUE "hit_ground".
 01 WS-EV-BOUNCE           PIC X(32) VALUE "bounce".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-N                   BINARY-LONG.
 01 WS-BOUNCY              BINARY-LONG.
 01 WS-SUPPRESSED          BINARY-LONG.
 01 WS-NEVER               BINARY-LONG.
 LINKAGE SECTION.
 COPY GEMOVE.
 01 L-SUPPORT              BINARY-LONG.
 PROCEDURE DIVISION USING MV-CTX L-SUPPORT.
     IF MV-WET = 0 AND MV-DY < 0
         COMPUTE EN-FALL-DIST(MV-ROW) = EN-FALL-DIST(MV-ROW) - MV-DY
     END-IF
     IF MV-ON-GROUND = 1
*>       bat, allay, bee, ghasts, parrot, phantom and boats override checkFallDamage with nothing
         MOVE 0 TO WS-NEVER WS-N
         INSPECT MV-KEY TALLYING WS-N FOR ALL "boat" ALL "raft"
         IF MV-KEY = "bat" OR MV-KEY = "allay" OR MV-KEY = "bee" OR MV-KEY = "ghast" OR MV-KEY = "happy_ghast"
                 OR MV-KEY = "parrot" OR MV-KEY = "phantom" OR WS-N > 0
             MOVE 1 TO WS-NEVER
         END-IF
         IF EN-FALL-DIST(MV-ROW) > 0
             IF WS-NEVER = 0
                 CALL "GAME-EVENT" USING MV-DIM MV-X MV-Y MV-Z WS-EV-HIT MV-ROW L-SUPPORT
             END-IF
             MOVE 0 TO EN-FALL-DIST(MV-ROW)
         END-IF
*>       restitution: landing faster than the gravity on a block with a restitution value, without the shift key
         IF MV-DY < -0.08 AND MV-SHIFT = 0 AND L-SUPPORT > 0 AND L-SUPPORT < CB-STATE-COUNT
             MOVE CB-S-BLOCK(L-SUPPORT + 1) TO WS-BLOCK
             MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY
             MOVE 0 TO WS-BOUNCY WS-N
             INSPECT WS-KEY TALLYING WS-N FOR ALL "_bed "
             IF WS-KEY = "slime_block" OR WS-KEY = "shelf_mushroom" OR WS-N > 0
                 MOVE 1 TO WS-BOUNCY
             END-IF
             IF WS-BOUNCY = 1
                 CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-SUPPRESSES WS-BLOCK WS-SUPPRESSED
                 IF WS-SUPPRESSED = 0
                     CALL "GAME-EVENT" USING MV-DIM MV-X MV-Y MV-Z WS-EV-BOUNCE MV-ROW WS-NO-STATE
                 END-IF
             END-IF
         END-IF
     END-IF
     IF MV-PLAYER > 0 AND MV-DY > 0
         MOVE 0 TO EN-FALL-DIST(MV-ROW)
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-FALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-MOVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GEMOVE.
 01 WS-EV-SPLASH           PIC X(32) VALUE "splash".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-EMITS               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-C1X                 BINARY-LONG.
 01 WS-C1Y                 BINARY-LONG.
 01 WS-C1Z                 BINARY-LONG.
 01 WS-C0Y                 BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-AIR1                BINARY-LONG.
 01 WS-AIR2                BINARY-LONG.
 01 WS-SUPPORT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-ON-GROUND.
     COMPUTE MV-DX = L-X - EN-X(L-ROW)
     COMPUTE MV-DY = L-Y - EN-Y(L-ROW)
     COMPUTE MV-DZ = L-Z - EN-Z(L-ROW)
*>   A displacement over 8 blocks is a teleport, not a movement.
     IF MV-DX * MV-DX + MV-DY * MV-DY + MV-DZ * MV-DZ > 64
         GOBACK
     END-IF
     MOVE L-ROW TO MV-ROW
     MOVE EN-DIM(L-ROW) TO MV-DIM
     MOVE L-X TO MV-X
     MOVE L-Y TO MV-Y
     MOVE L-Z TO MV-Z
     MOVE L-ON-GROUND TO MV-ON-GROUND
     MOVE EN-PLAYER(L-ROW) TO MV-PLAYER
*>   A spectator has noPhysics; a rider is carried (the vehicle posts instead).
     IF MV-PLAYER > 0
         IF PL-MODE(MV-PLAYER) = 3
             GOBACK
         END-IF
     END-IF
     IF EN-VEHICLE(L-ROW) > 0 OR EN-MOUNT(L-ROW) > 0
         GOBACK
     END-IF
     CALL "GAME-EVENT-ROW-KEY" USING L-ROW MV-KEY
*>   Entity.getMovementEmission: NONE for these types, and for a flying player or one sneaking on the ground.
     MOVE 1 TO WS-EMITS
     EVALUATE MV-KEY
         WHEN "item" WHEN "arrow" WHEN "spectral_arrow" WHEN "trident" WHEN "fishing_bobber" WHEN "experience_orb"
         WHEN "tnt" WHEN "falling_block" WHEN "end_crystal" WHEN "shulker"
             MOVE 0 TO WS-EMITS
     END-EVALUATE
     MOVE 0 TO MV-SHIFT MV-SWIMMING MV-CROUCH
     IF MV-PLAYER > 0
         COMPUTE WS-FLAGS = PL-POSE-FLAGS(MV-PLAYER) / 2
         IF FUNCTION MOD(WS-FLAGS, 2) = 1
             MOVE 1 TO MV-SHIFT
         END-IF
         IF PL-FLYING(MV-PLAYER) = 1 OR (L-ON-GROUND = 1 AND MV-SHIFT = 1)
             MOVE 0 TO WS-EMITS
         END-IF
         MOVE PL-SWIMMING(MV-PLAYER) TO MV-SWIMMING
         IF PL-POSE(MV-PLAYER) = 5
             MOVE 1 TO MV-CROUCH
         END-IF
     ELSE
         MOVE EN-CROUCHING(L-ROW) TO MV-CROUCH
     END-IF
*>   1. splash: the box touches water now and did not at the previous pass (the first pass of a row only records the state).
     IF MV-DX = 0 AND MV-DY = 0 AND MV-DZ = 0 AND EN-IN-WATER(L-ROW) > 0
         MOVE 0 TO MV-WET
         IF EN-IN-WATER(L-ROW) = 2
             MOVE 1 TO MV-WET
         END-IF
     ELSE
         CALL "FLUID-TOUCHES-WATER" USING MV-DIM L-X L-Y L-Z MV-WET
     END-IF
     IF EN-IN-WATER(L-ROW) = 1 AND MV-WET = 1
         CALL "GAME-EVENT" USING MV-DIM L-X L-Y L-Z WS-EV-SPLASH L-ROW WS-NO-STATE
     END-IF
     IF MV-WET = 1
         MOVE 2 TO EN-IN-WATER(L-ROW)
         MOVE 0 TO EN-FALL-DIST(L-ROW)
     ELSE
         MOVE 1 TO EN-IN-WATER(L-ROW)
     END-IF
*>   The supporting block: the cell holding (x, y - 1e-5, z), or the cell below it when that one is air and the entity is on the ground (a fence, a wall: the legacy cell is then the same cell).
     COMPUTE WS-C1X = FUNCTION INTEGER(L-X)
     COMPUTE WS-C1Y = FUNCTION INTEGER(L-Y - 0.00001)
     COMPUTE WS-C1Z = FUNCTION INTEGER(L-Z)
     CALL "WORLD-GET-BLOCK" USING MV-DIM WS-C1X WS-C1Y WS-C1Z MV-S1
     CALL "GAME-EVENT-IS-AIR" USING MV-S1 WS-AIR1
     MOVE 0 TO MV-SAME
     IF L-ON-GROUND = 1 AND WS-AIR1 = 1
         COMPUTE WS-C0Y = WS-C1Y - 1
         CALL "WORLD-GET-BLOCK" USING MV-DIM WS-C1X WS-C0Y WS-C1Z WS-SB
         CALL "GAME-EVENT-IS-AIR" USING WS-SB WS-AIR2
         IF WS-AIR2 = 0
             MOVE WS-SB TO MV-S1
             MOVE 1 TO MV-SAME
         END-IF
     END-IF
     MOVE MV-S1 TO MV-S0
     IF MV-SAME = 0
         COMPUTE WS-C0Y = FUNCTION INTEGER(L-Y - 0.2)
         IF WS-C0Y = WS-C1Y
             MOVE 1 TO MV-SAME
         ELSE
             CALL "WORLD-GET-BLOCK" USING MV-DIM WS-C1X WS-C0Y WS-C1Z MV-S0
         END-IF
     END-IF
     MOVE MV-S1 TO WS-SUPPORT
     IF WS-EMITS = 1
         IF MV-PLAYER > 0
             CALL "GAME-EVENT-PASS" USING MV-CTX
             CALL "GAME-EVENT-FALL" USING MV-CTX WS-SUPPORT
         ELSE
             CALL "GAME-EVENT-FALL" USING MV-CTX WS-SUPPORT
             CALL "GAME-EVENT-PASS" USING MV-CTX
         END-IF
     ELSE
         CALL "GAME-EVENT-FALL" USING MV-CTX WS-SUPPORT
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-MOVED.
