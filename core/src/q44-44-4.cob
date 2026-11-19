*> Residual mob questions, part 4 (docs/protocol/44-residual-mob-questions-4-land-animals.md; lane 002-lane-p49i, T22580 and following): the pure rules of section 1 (the shared Brain
*> behaviours: long jump, the land and liquid finders, croak, the frog tongue, MobSensor) and section 2 (equines). Every random draw and world fact is an argument. The jump vector
*> and the llama caravan already live in mob-44-m.cob (M44-JUMP-VECTOR) and mob-44-p.cob (M44-LLAMA-CARAVAN); the strength and the jump scale in mob-19-3.cob.
*>   Q4-LJ-WEIGHT USING dx, dy, dz, weight out          the weight of a candidate block: ceil(distance squared to the mob's block)
*>   Q4-LJ-START USING on ground, in water or lava, in honey, cooldown sample, ok out, cooldown out
*>   Q4-LJ-LAUNCH USING speed, jump boost power, scale out        the motion scale (|v| + boost) / |v|
*>   Q4-LJ-CONTINUE USING start unchanged, tries, in water, chosen, candidates left, continue out
*>   Q4-LJ-END USING mid jump present, cooldown sample, cooldown out, erase look out
*>   Q4-LJ-MID-STOP USING on ground, vx, vz, cooldown sample, nvx out, nvz out, cooldown out
*>   Q4-LJ-PICK USING count, weights, preferred flags, draws, wanting preferred, index out
*>   Q4-FINDER-TIMER USING kind, now, next, scan out, new next out
*>   Q4-FINDER-START USING attack target, walk target, ok out;  Q4-FINDER-PARAMS USING kind, swim, radius out, speed out, completion out
*>   Q4-FINDER-RUNS USING kind, in tag fluid, ok out
*>   Q4-LAND-OK USING differs, fluid empty, free, sturdy below, ok out;  Q4-LAND-NEAR-OK USING differs, free, shape below, neighbour ok, ok out
*>   Q4-LIQUID-PICK USING count, in tag, air above, distance, index out
*>   Q4-CROAK-START USING standing, walk target, ok out;  Q4-CROAK-BEGIN USING in liquid, croaking out, counter out;  Q4-CROAK-TICK USING counter, goes on out, new counter out
*>   Q4-FROG-CAN-EAT USING cube, size, in food tag, ok out
*>   Q4-TONGUE-START USING walk target, attack target, panicking, reachable, croaking, can eat, ok out
*>   Q4-TONGUE-TICK USING state, distance, path counter, timer, new state out, new timer out, new counter out, pull out, walk out, eat out
*>   Q4-MOB-SENSOR USING ready, matched, memory out
*>   Q4-LLAMA-SLOTS USING chest, strength, donkey or mule, columns out, slots out
*>   Q4-PLAYER-JUMP USING power, saddled, rear out, stored out
*>   Q4-RIDDEN-PITCH USING rider pitch, mount pitch out
*>   Q4-CAMEL-POSE-TIME USING game time, last change tick, pose time out;  Q4-CAMEL-STAND-INSTANT USING game time, tick out
*>   Q4-CAMEL-SIT-OK USING in water, pose time, leashed, on ground, controlling passenger, can change pose, ok out
*>   Q4-CAMEL-CONST USING code, out;  Q4-CAMEL-TEMPT USING baby, close enough out, speed out;  Q4-HUSK-TRAIT USING code, out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-WEIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-WEIGHT.
     COMPUTE L-WEIGHT = L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ
     GOBACK.
 END PROGRAM Q4-LJ-WEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-START.
*> checkExtraStartConditions (1.1 step 1): on the ground, not in water or lava, not standing in a honey block. When it fails the cooldown becomes sample / 2 (integer division).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-HONEY                BINARY-LONG.
 01 L-SAMPLE               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-FLUID L-HONEY L-SAMPLE L-OK L-COOLDOWN.
     MOVE 0 TO L-OK L-COOLDOWN
     IF L-GROUND = 1 AND L-FLUID = 0 AND L-HONEY = 0
         MOVE 1 TO L-OK
     ELSE
         COMPUTE L-COOLDOWN = FUNCTION INTEGER(L-SAMPLE / 2)
     END-IF
     GOBACK.
 END PROGRAM Q4-LJ-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-LAUNCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                FLOAT-LONG.
 01 L-BOOST                FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SPEED L-BOOST L-SCALE.
     MOVE 1 TO L-SCALE
     IF L-SPEED > 0
         COMPUTE L-SCALE = (L-SPEED + L-BOOST) / L-SPEED
     END-IF
     GOBACK.
 END PROGRAM Q4-LJ-LAUNCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-CONTINUE.
*> The behaviour goes on while the start position is unchanged, tries > 0, the mob is not in water and (a jump is chosen or candidates remain) (1.1 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UNCHANGED            BINARY-LONG.
 01 L-TRIES                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CHOSEN               BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-GOES-ON              BINARY-LONG.
 PROCEDURE DIVISION USING L-UNCHANGED L-TRIES L-WATER L-CHOSEN L-LEFT L-GOES-ON.
     MOVE 0 TO L-GOES-ON
     IF L-UNCHANGED = 1 AND L-TRIES > 0 AND L-WATER = 0 AND (L-CHOSEN = 1 OR L-LEFT > 0)
         MOVE 1 TO L-GOES-ON
     END-IF
     GOBACK.
 END PROGRAM Q4-LJ-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-END.
*> When the behaviour ends and LONG_JUMP_MID_JUMP is still absent the cooldown is sample / 2 and LOOK_TARGET is erased (1.1 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MID                  BINARY-LONG.
 01 L-SAMPLE               BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-ERASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MID L-SAMPLE L-COOLDOWN L-ERASE.
     MOVE 0 TO L-COOLDOWN L-ERASE
     IF L-MID = 0
         COMPUTE L-COOLDOWN = FUNCTION INTEGER(L-SAMPLE / 2)
         MOVE 1 TO L-ERASE
     END-IF
     GOBACK.
 END PROGRAM Q4-LJ-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-MID-STOP.
*> LongJumpMidJump stop (1.1): on the ground the horizontal motion is multiplied by (0.1, 1, 0.1); the cooldown is the full sample (the prepare path used half).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SAMPLE               BINARY-LONG.
 01 L-NVX                  FLOAT-LONG.
 01 L-NVZ                  FLOAT-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-VX L-VZ L-SAMPLE L-NVX L-NVZ L-COOLDOWN.
     MOVE L-VX TO L-NVX
     MOVE L-VZ TO L-NVZ
     IF L-GROUND = 1
         COMPUTE L-NVX = L-VX * 0.1
         COMPUTE L-NVZ = L-VZ * 0.1
     END-IF
     MOVE L-SAMPLE TO L-COOLDOWN
     GOBACK.
 END PROGRAM Q4-LJ-MID-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LJ-PICK.
*> The candidate draw of LongJumpToPreferredBlock (1.1). USING count, weights (weight per candidate), preferred flags (1: the block below is in the tag), draws (the nextInt(total weight)
*> of each successive draw), wanting preferred (the roll nextFloat < chance), index out (0 none). Each draw picks the candidate where the running weight passes it and removes it.
*> Not wanting preferred: the first draw's candidate. Wanting preferred: the first drawn candidate that is preferred, else (the candidates exhausted) the first not preferred one drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-DRAW-N              BINARY-LONG.
 01 WS-FIRST-NOT           BINARY-LONG.
 01 WS-GONE.
    05 WS-G                PIC 9 OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-WEIGHTS.
    05 L-WEIGHT            BINARY-LONG OCCURS 64 TIMES.
 01 L-PREFERRED.
    05 L-PREF              PIC 9 OCCURS 64 TIMES.
 01 L-DRAWS.
    05 L-DRAW              BINARY-LONG OCCURS 64 TIMES.
 01 L-WANT                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-WEIGHTS L-PREFERRED L-DRAWS L-WANT L-INDEX.
     MOVE 0 TO L-INDEX WS-FIRST-NOT WS-DRAW-N
     MOVE ALL "0" TO WS-GONE
     MOVE L-COUNT TO WS-LEFT
     PERFORM UNTIL WS-LEFT = 0 OR L-INDEX > 0
         ADD 1 TO WS-DRAW-N
         MOVE 0 TO WS-TOTAL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             IF WS-G(WS-I) = 0
                 ADD L-WEIGHT(WS-I) TO WS-TOTAL
             END-IF
         END-PERFORM
         MOVE 0 TO WS-RUN WS-PICK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR WS-PICK > 0
             IF WS-G(WS-I) = 0
                 ADD L-WEIGHT(WS-I) TO WS-RUN
                 IF L-DRAW(WS-DRAW-N) < WS-RUN
                     MOVE WS-I TO WS-PICK
                 END-IF
             END-IF
         END-PERFORM
         MOVE "1" TO WS-G(WS-PICK)
         SUBTRACT 1 FROM WS-LEFT
         EVALUATE TRUE
             WHEN L-WANT = 0
                 MOVE WS-PICK TO L-INDEX
             WHEN L-PREF(WS-PICK) = 1
                 MOVE WS-PICK TO L-INDEX
             WHEN WS-FIRST-NOT = 0
                 MOVE WS-PICK TO WS-FIRST-NOT
         END-EVALUATE
     END-PERFORM
     IF L-INDEX = 0
         MOVE WS-FIRST-NOT TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM Q4-LJ-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-FINDER-TIMER.
*> The private next-allowed-time counter of the three finders (1.2 table). kind 1 TryFindLand (60), 2 TryFindLandNearLiquid (40), 3 TryFindLiquid (suppressed: +22 with no search, after a
*> search +40). When now < next the call succeeds without scanning and the counter is pushed to now + the suppressed amount; otherwise scan = 1 and the counter becomes now + the amount.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUPPRESSED          BINARY-LONG.
 01 WS-SEARCHED            BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NOW                  BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-SCAN                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-NOW L-NEXT L-SCAN L-NEW.
     EVALUATE L-KIND
         WHEN 1
             MOVE 60 TO WS-SUPPRESSED WS-SEARCHED
         WHEN 2
             MOVE 40 TO WS-SUPPRESSED WS-SEARCHED
         WHEN OTHER
             MOVE 22 TO WS-SUPPRESSED
             MOVE 40 TO WS-SEARCHED
     END-EVALUATE
     IF L-NOW < L-NEXT
         MOVE 0 TO L-SCAN
         COMPUTE L-NEW = L-NOW + WS-SUPPRESSED
     ELSE
         MOVE 1 TO L-SCAN
         COMPUTE L-NEW = L-NOW + WS-SEARCHED
     END-IF
     GOBACK.
 END PROGRAM Q4-FINDER-TIMER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-FINDER-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACK               BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACK L-WALK L-OK.
     MOVE 0 TO L-OK
     IF L-ATTACK = 0 AND L-WALK = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-FINDER-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-FINDER-PARAMS.
*> kind 1 TryFindLand: idle (6, 1.0) or swim (8, 1.5), completion range 1; kind 2 TryFindLandNearLiquid (8, 1.0), completion 0; kind 3 TryFindLiquid: completion 0 (radius and speed are the caller's).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SWIM                 BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-COMPLETION           BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SWIM L-RADIUS L-SPEED L-COMPLETION.
     MOVE 0 TO L-RADIUS L-COMPLETION
     MOVE 1.0 TO L-SPEED
     EVALUATE L-KIND
         WHEN 1
             MOVE 6 TO L-RADIUS
             MOVE 1 TO L-COMPLETION
             IF L-SWIM = 1
                 MOVE 8 TO L-RADIUS
                 MOVE 1.5 TO L-SPEED
             END-IF
         WHEN 2
             MOVE 8 TO L-RADIUS
     END-EVALUATE
     GOBACK.
 END PROGRAM Q4-FINDER-PARAMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-FINDER-RUNS.
*> TryFindLand runs when the mob's block fluid is in tag water; TryFindLandNearLiquid and TryFindLiquid when it is not in their fluid tag.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-IN-TAG               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-IN-TAG L-OK.
     MOVE 0 TO L-OK
     IF (L-KIND = 1 AND L-IN-TAG = 1) OR (L-KIND > 1 AND L-IN-TAG = 0)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-FINDER-RUNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LAND-OK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFERS              BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFERS L-EMPTY L-FREE L-STURDY L-OK.
     MOVE 0 TO L-OK
     IF L-DIFFERS = 1 AND L-EMPTY = 1 AND L-FREE = 1 AND L-STURDY = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-LAND-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LAND-NEAR-OK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFERS              BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFERS L-FREE L-SHAPE L-NEIGHBOUR L-OK.
     MOVE 0 TO L-OK
     IF L-DIFFERS = 1 AND L-FREE = 1 AND L-SHAPE = 1 AND L-NEIGHBOUR = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-LAND-NEAR-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LIQUID-PICK.
*> TryFindLiquid search (1.2): the first liquid block of the tag whose block above is air; failing that the first liquid block of the tag at least 1.5 from the mob (distance table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-IN-TAG.
    05 L-TAG               PIC 9 OCCURS 64 TIMES.
 01 L-AIR-ABOVE.
    05 L-AIR               PIC 9 OCCURS 64 TIMES.
 01 L-DISTANCES.
    05 L-DIST              FLOAT-LONG OCCURS 64 TIMES.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-IN-TAG L-AIR-ABOVE L-DISTANCES L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR L-INDEX > 0
         IF L-TAG(WS-I) = 1 AND L-AIR(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR L-INDEX > 0
         IF L-TAG(WS-I) = 1 AND L-DIST(WS-I) >= 1.5
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q4-LIQUID-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CROAK-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STANDING             BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STANDING L-WALK L-OK.
     MOVE 0 TO L-OK
     IF L-STANDING = 1 AND L-WALK = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-CROAK-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CROAK-BEGIN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIQUID               BINARY-LONG.
 01 L-CROAKING             BINARY-LONG.
 01 L-COUNTER              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIQUID L-CROAKING L-COUNTER.
     MOVE 0 TO L-CROAKING L-COUNTER
     IF L-LIQUID = 0
         MOVE 1 TO L-CROAKING
     END-IF
     GOBACK.
 END PROGRAM Q4-CROAK-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CROAK-TICK.
*> The croak continues while the counter < 60 (the counter rises by 1 a tick); the stop sets the pose STANDING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-GOES-ON              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-GOES-ON L-NEW.
     MOVE 0 TO L-GOES-ON
     IF L-COUNTER < 60
         MOVE 1 TO L-GOES-ON
     END-IF
     COMPUTE L-NEW = L-COUNTER + 1
     GOBACK.
 END PROGRAM Q4-CROAK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-FROG-CAN-EAT.
*> Frog.canEat (1.4): false for a cube mob whose size is not 1; everything else is edible when in the entity type tag frog_food (slime, magma_cube).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CUBE                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CUBE L-SIZE L-TAG L-OK.
     MOVE 0 TO L-OK
     IF NOT (L-CUBE = 1 AND L-SIZE NOT = 1)
         MOVE L-TAG TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-FROG-CAN-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-TONGUE-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WALK                 BINARY-LONG.
 01 L-ATTACK               BINARY-LONG.
 01 L-PANIC                BINARY-LONG.
 01 L-REACHABLE            BINARY-LONG.
 01 L-CROAKING             BINARY-LONG.
 01 L-CAN-EAT              BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WALK L-ATTACK L-PANIC L-REACHABLE L-CROAKING L-CAN-EAT L-OK.
     MOVE 0 TO L-OK
     IF L-WALK = 0 AND L-ATTACK = 1 AND L-PANIC = 0 AND L-REACHABLE = 1 AND L-CROAKING = 0 AND L-CAN-EAT = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-TONGUE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-TONGUE-TICK.
*> ShootTongue.tick (1.4 table). States 1 MOVE_TO_TARGET, 2 CATCH_ANIMATION, 3 EAT_ANIMATION, 4 DONE. MOVE: below 1.75 from the target the tongue sound plays, the pose USING_TONGUE, the
*> target is pulled at 0.75 (pull 1), the timer is 0 and the state CATCH; otherwise at a path counter <= 0 the walk target is set (speed 2.0, walk 1) and the counter is 10, else it drops by 1.
*> CATCH: timer + 1 first, at >= 6 the state is EAT and eatEntity runs (eat 1). EAT: at timer >= 10 DONE, else timer + 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-COUNTER              BINARY-LONG.
 01 L-TIMER                BINARY-LONG.
 01 L-NEW-STATE            BINARY-LONG.
 01 L-NEW-TIMER            BINARY-LONG.
 01 L-NEW-COUNTER          BINARY-LONG.
 01 L-PULL                 BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-EAT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DISTANCE L-COUNTER L-TIMER L-NEW-STATE L-NEW-TIMER L-NEW-COUNTER L-PULL L-WALK L-EAT.
     MOVE L-STATE TO L-NEW-STATE
     MOVE L-TIMER TO L-NEW-TIMER
     MOVE L-COUNTER TO L-NEW-COUNTER
     MOVE 0 TO L-PULL L-WALK L-EAT
     EVALUATE L-STATE
         WHEN 1
             IF L-DISTANCE < 1.75
                 MOVE 1 TO L-PULL
                 MOVE 0 TO L-NEW-TIMER
                 MOVE 2 TO L-NEW-STATE
             ELSE
                 IF L-COUNTER <= 0
                     MOVE 1 TO L-WALK
                     MOVE 10 TO L-NEW-COUNTER
                 ELSE
                     SUBTRACT 1 FROM L-NEW-COUNTER
                 END-IF
             END-IF
         WHEN 2
             COMPUTE L-NEW-TIMER = L-TIMER + 1
             IF L-NEW-TIMER >= 6
                 MOVE 3 TO L-NEW-STATE
                 MOVE 1 TO L-EAT
             END-IF
         WHEN 3
             IF L-TIMER >= 10
                 MOVE 4 TO L-NEW-STATE
             ELSE
                 COMPUTE L-NEW-TIMER = L-TIMER + 1
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q4-TONGUE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-MOB-SENSOR.
*> MobSensor pass (1.5): not ready erases the memory (0); ready and a matching entity sets it true for 80 ticks (1); ready without a match leaves it as it is (2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-READY                BINARY-LONG.
 01 L-MATCHED              BINARY-LONG.
 01 L-MEMORY               BINARY-LONG.
 PROCEDURE DIVISION USING L-READY L-MATCHED L-MEMORY.
     EVALUATE TRUE
         WHEN L-READY = 0
             MOVE 0 TO L-MEMORY
         WHEN L-MATCHED = 1
             MOVE 1 TO L-MEMORY
         WHEN OTHER
             MOVE 2 TO L-MEMORY
     END-EVALUATE
     GOBACK.
 END PROGRAM Q4-MOB-SENSOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-LLAMA-SLOTS.
*> Inventory (2.2): columns = strength with a chest, else 0 (the donkey and mule have 5 columns); the slot count is 3 x columns.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHEST                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-EQUINE               BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-SLOTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHEST L-STRENGTH L-EQUINE L-COLUMNS L-SLOTS.
     MOVE 0 TO L-COLUMNS
     IF L-CHEST = 1
         MOVE L-STRENGTH TO L-COLUMNS
         IF L-EQUINE = 1
             MOVE 5 TO L-COLUMNS
         END-IF
     END-IF
     COMPUTE L-SLOTS = 3 * L-COLUMNS
     GOBACK.
 END PROGRAM Q4-LLAMA-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-PLAYER-JUMP.
*> onPlayerJump (2.1, saddled only): p < 0 becomes 0 and does not make the horse stand; otherwise the horse may rear. The stored pending scale is 0.4 + 0.4 p / 90, 1.0 from 90 up
*> (in thousandths).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-SADDLED              BINARY-LONG.
 01 L-REAR                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-SADDLED L-REAR L-STORED.
     MOVE 0 TO L-REAR L-STORED
     IF L-SADDLED = 1
         MOVE L-POWER TO WS-P
         IF WS-P >= 0
             MOVE 1 TO L-REAR
         ELSE
             MOVE 0 TO WS-P
         END-IF
         CALL "M19-HORSE-JUMP-SCALE" USING WS-P L-STORED
     END-IF
     GOBACK.
 END PROGRAM Q4-PLAYER-JUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-RIDDEN-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RIDER-PITCH          FLOAT-LONG.
 01 L-MOUNT-PITCH          FLOAT-LONG.
 PROCEDURE DIVISION USING L-RIDER-PITCH L-MOUNT-PITCH.
     COMPUTE L-MOUNT-PITCH = L-RIDER-PITCH / 2
     GOBACK.
 END PROGRAM Q4-RIDDEN-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CAMEL-POSE-TIME.
*> Camel.getPoseTime (2.3): game time - |last pose change tick| (the absolute value applies only to the stored tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GAME                 BINARY-DOUBLE.
 01 L-LAST                 BINARY-DOUBLE.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-GAME L-LAST L-TIME.
     COMPUTE L-TIME = L-GAME - FUNCTION ABS(L-LAST)
     GOBACK.
 END PROGRAM Q4-CAMEL-POSE-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CAMEL-STAND-INSTANT.
*> standUpInstantly: the last change tick becomes max(0, game time - 52 - 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GAME                 BINARY-DOUBLE.
 01 L-TICK                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-GAME L-TICK.
     COMPUTE L-TICK = L-GAME - 53
     IF L-TICK < 0
         MOVE 0 TO L-TICK
     END-IF
     GOBACK.
 END PROGRAM Q4-CAMEL-STAND-INSTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CAMEL-SIT-OK.
*> RandomSitting start (2.3): not in water, pose time >= 400 (20 x 20), not leashed, on the ground, no controlling passenger and the pose change does not suffocate.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-POSE-TIME            BINARY-DOUBLE.
 01 L-LEASHED              BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-CAN-CHANGE           BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-POSE-TIME L-LEASHED L-GROUND L-PASSENGER L-CAN-CHANGE L-OK.
     MOVE 0 TO L-OK
     IF L-WATER = 0 AND L-POSE-TIME >= 400 AND L-LEASHED = 0 AND L-GROUND = 1 AND L-PASSENGER = 0 AND L-CAN-CHANGE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q4-CAMEL-SIT-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CAMEL-CONST.
*> The camel constants (2.3): 1 dash cooldown 55, 2 minimum dash duration 5, 3 sit down 40, 4 stand up 52, 5 idle minimum 80, 6 baby scale (thousandths) 600, 7 sitting height difference
*> (thousandths) 1430, 8 running speed bonus (thousandths) 100, 9 dash vertical momentum (ten thousandths) 14285, 10 dash horizontal momentum (ten thousandths) 222222.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-OUT.
     EVALUATE L-CODE
         WHEN 1
             MOVE 55 TO L-OUT
         WHEN 2
             MOVE 5 TO L-OUT
         WHEN 3
             MOVE 40 TO L-OUT
         WHEN 4
             MOVE 52 TO L-OUT
         WHEN 5
             MOVE 80 TO L-OUT
         WHEN 6
             MOVE 600 TO L-OUT
         WHEN 7
             MOVE 1430 TO L-OUT
         WHEN 8
             MOVE 100 TO L-OUT
         WHEN 9
             MOVE 14285 TO L-OUT
         WHEN OTHER
             MOVE 222222 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q4-CAMEL-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-CAMEL-TEMPT.
*> FollowTemptation (2.3): the speed is 2.5 for everyone; the close-enough value is 2.5 for a baby and 3.5 for an adult, compared with the squared distance.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-CLOSE                FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-BABY L-CLOSE L-SPEED.
     MOVE 2.5 TO L-SPEED
     MOVE 3.5 TO L-CLOSE
     IF L-BABY = 1
         MOVE 2.5 TO L-CLOSE
     END-IF
     GOBACK.
 END PROGRAM Q4-CAMEL-TEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q4-HUSK-TRAIT.
*> The camel husk (2.3): 1 removeWhenFarAway, 0 canMate, 0 canFallInLove, 0 canBeABaby (codes 2 to 4), 5 charge speed modifier (thousandths) 4000.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-OUT.
     MOVE 0 TO L-OUT
     IF L-CODE = 1
         MOVE 1 TO L-OUT
     END-IF
     IF L-CODE = 5
         MOVE 4000 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q4-HUSK-TRAIT.
