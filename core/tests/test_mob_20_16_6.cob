*> Acceptance test (lane p49u; docs/protocol/20 section 16.1 and 16.4): the breeze's brain wiring through whole mob steps. A shot is armed only by a long jump landing (breeze_shoot 100), a slide's
*> end (60) or ShootWhenStuck (60), and each arming gives exactly one shot; the long jump inhales 10 ticks (pose INHALING 1), flies without horizontal friction (pose LONG_JUMPING 2) and lands with the
*> jump cooldown 10 and breeze_shoot 100; a target 3 blocks away cannot be jumped to, so the slide sets a walk target (the activity becomes IDLE, the sink runs 20 to 40 ticks in pose SLIDING 3 and
*> arms the shot for 60 ticks when it stops); a breeze in water with no jump arms a shot by itself; the 200 tick cant-reach rule and its erasure by StartAttacking; the stroll factor 0.36 (0.6 squared).
*> Poses: BZ-POSE of BREEZESTATE.cpy. The state of one breeze is found with BZ-FIND (its slot).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BREEZESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 64.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-INHALE-AT           BINARY-LONG.
 01 WS-JUMP-AT             BINARY-LONG.
 01 WS-LAND-AT             BINARY-LONG.
 01 WS-SHOT-AT             BINARY-LONG.
 01 WS-SHOTS               BINARY-LONG.
 01 WS-PREV-DRAW           BINARY-LONG.
 01 WS-PREV-POSE           BINARY-LONG.
 01 WS-CD-AT-LAND          BINARY-LONG.
 01 WS-SHOOT-AT-LAND       BINARY-LONG.
 01 WS-DRAW-AT-LAND        BINARY-LONG.
 01 WS-DRAW-INH            BINARY-LONG.
 01 WS-X-PREV              FLOAT-LONG.
 01 WS-STEP-A              FLOAT-LONG.
 01 WS-STEP-B              FLOAT-LONG.
 01 WS-STEP-N              BINARY-LONG.
 01 WS-STOP-AT             BINARY-LONG.
 01 WS-SHOOT-AT-STOP       BINARY-LONG.
 01 WS-SLIDE-POSE-AT       BINARY-LONG.
 01 WS-ACT-IDLE-AT         BINARY-LONG.
 01 WS-MOVED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-KEY24               PIC X(24).
 01 WS-LABEL               PIC X(160).
 01 WS-HONEY               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-SEEN-POSE           BINARY-LONG.
 01 WS-SEEN-JSET           BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WALL-X              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 32
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 32
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND

*>   A breeze 10 blocks from its target (survival): the first tick starts the long jump, not a shot.
     MOVE 10 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     MOVE 0 TO WS-INHALE-AT WS-JUMP-AT WS-LAND-AT WS-SHOT-AT WS-SHOTS WS-PREV-DRAW WS-PREV-POSE
     MOVE 0 TO WS-CD-AT-LAND WS-SHOOT-AT-LAND WS-DRAW-AT-LAND WS-DRAW-INH WS-STEP-N
     MOVE 0 TO WS-STEP-A WS-STEP-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE EN-X(WS-MOB) TO WS-X-PREV
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         IF WS-SLOT > 0
             IF BZ-POSE(WS-SLOT) = 1 AND WS-INHALE-AT = 0
                 MOVE WS-I TO WS-INHALE-AT
                 MOVE EN-DRAW(WS-MOB) TO WS-DRAW-INH
             END-IF
             IF BZ-POSE(WS-SLOT) = 2 AND WS-JUMP-AT = 0
                 MOVE WS-I TO WS-JUMP-AT
             END-IF
*>           Two displacements in the middle of the flight: the horizontal step of the tick is the same (no friction).
             IF BZ-POSE(WS-SLOT) = 2 AND WS-PREV-POSE = 2
                 ADD 1 TO WS-STEP-N
                 IF WS-STEP-N = 3
                     COMPUTE WS-STEP-A = EN-X(WS-MOB) - WS-X-PREV
                 END-IF
                 IF WS-STEP-N = 4
                     COMPUTE WS-STEP-B = EN-X(WS-MOB) - WS-X-PREV
                 END-IF
             END-IF
             IF WS-PREV-POSE = 2 AND BZ-POSE(WS-SLOT) = 0 AND WS-LAND-AT = 0
                 MOVE WS-I TO WS-LAND-AT
                 MOVE BZ-CD(WS-SLOT) TO WS-CD-AT-LAND
                 MOVE BZ-SHOOT(WS-SLOT) TO WS-SHOOT-AT-LAND
                 MOVE EN-DRAW(WS-MOB) TO WS-DRAW-AT-LAND
             END-IF
             MOVE BZ-POSE(WS-SLOT) TO WS-PREV-POSE
         END-IF
         IF WS-PREV-DRAW NOT = 2 AND EN-DRAW(WS-MOB) = 2
             ADD 1 TO WS-SHOTS
             IF WS-SHOTS = 1
                 MOVE WS-I TO WS-SHOT-AT
             END-IF
         END-IF
         IF WS-SHOTS >= 1 AND WS-LAND-AT > 0 AND WS-I >= WS-LAND-AT + 40
             EXIT PERFORM
         END-IF
         MOVE EN-DRAW(WS-MOB) TO WS-PREV-DRAW
     END-PERFORM
     MOVE "acceptance US15 20§16.1 the first tick of a breeze with a target 10 blocks away starts the long jump (pose INHALING)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INHALE-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 no shot is started while the jump has not landed (EN-DRAW 0 in the inhale)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DRAW-INH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the jump starts on the tick that finds breeze_jump_inhaling (10 ticks) gone: tick 11" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-JUMP-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the flight keeps its horizontal step (discard friction)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-STEP-A * 1000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-STEP-B * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the flight moves toward the target (+x)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STEP-A > 0.05
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the landing sets the jump cooldown 10 (no hurt_by)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-CD-AT-LAND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the landing arms breeze_shoot for 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-SHOOT-AT-LAND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 the shot follows the landing, not before it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LAND-AT > 0 AND WS-SHOT-AT > WS-LAND-AT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 a landing arms exactly one shot (40 ticks after it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHOTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§16.1 the shot's stop erased breeze_shoot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BZ-SHOOT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   A target 3 blocks away cannot be jumped to: the slide runs (walk target, activity IDLE, pose SLIDING 20 to 40 ticks) and arms the shot for 60 ticks when it stops.
     MOVE 3 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     MOVE EN-X(WS-MOB) TO WS-X0
     MOVE 0 TO WS-STOP-AT WS-SHOOT-AT-STOP WS-SLIDE-POSE-AT WS-ACT-IDLE-AT WS-INHALE-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         IF WS-I = 1
             MOVE BZ-WALK(WS-SLOT) TO WS-PREV-POSE
         END-IF
         IF BZ-POSE(WS-SLOT) = 1
             MOVE WS-I TO WS-INHALE-AT
         END-IF
         IF BZ-ACT(WS-SLOT) = 2 AND WS-ACT-IDLE-AT = 0
             MOVE WS-I TO WS-ACT-IDLE-AT
         END-IF
         IF BZ-POSE(WS-SLOT) = 3 AND WS-SLIDE-POSE-AT = 0
             MOVE WS-I TO WS-SLIDE-POSE-AT
         END-IF
         IF WS-SLIDE-POSE-AT > 0 AND BZ-POSE(WS-SLOT) = 0 AND WS-STOP-AT = 0
             MOVE WS-I TO WS-STOP-AT
             MOVE BZ-SHOOT(WS-SLOT) TO WS-SHOOT-AT-STOP
             COMPUTE WS-MOVED = FUNCTION SQRT((EN-X(WS-MOB) - WS-X0) ** 2 + (EN-Z(WS-MOB) - WS-Z) ** 2)
             EXIT PERFORM
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§16.4 a target 3 blocks away is too close for the long jump (never INHALING)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INHALE-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 the first tick's slide sets the walk target" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PREV-POSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 a walk target makes the activity IDLE at the end of that tick (seen after tick 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ACT-IDLE-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 the slide sink starts in IDLE with the pose SLIDING (tick 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SLIDE-POSE-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 the sink stops within 40 ticks of its start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STOP-AT > 0 AND WS-STOP-AT <= 42
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 its stop arms breeze_shoot for 60 ticks (the target is present)" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-SHOOT-AT-STOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.5 the slide walked (more than 1 block)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MOVED > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§16.1 after the slide the walk target is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BZ-WALK(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM STEP-MOB
     MOVE "acceptance US15 20§16.1 the activity is FIGHT again and the armed shot starts (EN-DRAW 1)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-ACT(WS-SLOT) * 10 + EN-DRAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   ShootWhenStuck: in water, with no jump possible (3 blocks), it arms one shot by itself and does not slide (not in water is a Slide condition).
     MOVE 3 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-MOB))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-MOB))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-MOB))
     PERFORM VARYING WS-FX FROM WS-BX BY 1 UNTIL WS-FX > WS-BX
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-BZ WS-WATER
     END-PERFORM
     PERFORM STEP-MOB
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§16.1 ShootWhenStuck in water arms breeze_shoot for 60 ticks" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE BZ-SHOOT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.5 a breeze in water does not slide (no walk target, standing)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-WALK(WS-SLOT) * 10 + BZ-POSE(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM STEP-MOB
     MOVE "acceptance US15 20§16.1 the armed shot starts on the next tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-DRAW(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   The 200 tick rule: with the memory cant_reach_walk_target_since 200 ticks old the target is kept, 201 ticks old it is erased; StartAttacking erases the memory when it sets a target.
     MOVE 10 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     PERFORM STEP-MOB
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE 1 TO BZ-CANT-ON(WS-SLOT)
     COMPUTE BZ-CANT-AT(WS-SLOT) = CW-TICKS - 200
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "acceptance US15 20§16.1 a cant-reach memory 200 ticks old keeps the target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE BZ-CANT-AT(WS-SLOT) = CW-TICKS - 201
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "acceptance US15 20§16.1 one 201 ticks old erases the target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BZ-CANT-ON(WS-SLOT)
     MOVE 0 TO EN-TARGET(WS-MOB) EN-TARGET-ID(WS-MOB) BZ-HAD(WS-SLOT)
     PERFORM STEP-MOB
     MOVE "acceptance US15 20§16.1 StartAttacking sets the target and erases the cant-reach memory" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-PLAYER * 10
     COMPUTE TL-OBSERVED-N = EN-TARGET(WS-MOB) * 10 + BZ-CANT-ON(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB


*>   The jump vector can fail: a target 23.5 blocks away, looking toward the breeze's far side (head yaw 90 = -x ... the point behind it lies farther away): every angle needs more than 1.4: the pose goes back to STANDING
*>   with no cooldown after the inhale.
     MOVE 90 TO PL-YAW(WS-PLAYER)
     MOVE 23.5 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     MOVE 0 TO WS-SEEN-POSE WS-SEEN-JSET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         IF BZ-POSE(WS-SLOT) = 2
             MOVE 1 TO WS-SEEN-POSE
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§16.4 a jump with no feasible angle ends back in STANDING after the inhale, no cooldown, no flight" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SEEN-POSE * 1000 + BZ-POSE(WS-SLOT) * 100 + BZ-JSET(WS-SLOT) * 10 + BZ-CD(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE 0 TO PL-YAW(WS-PLAYER)

*>   hurt_by present: the landing's cooldown is 2. A flight that has run 200 ticks ends (the behaviour's maximum duration).
     MOVE 10 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     MOVE 0 TO WS-LAND-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR WS-LAND-AT > 0
         MOVE 100 TO EN-KILLER-AGE(WS-MOB)
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         IF WS-PREV-POSE = 2 AND BZ-POSE(WS-SLOT) = 0
             MOVE WS-I TO WS-LAND-AT
         END-IF
         MOVE BZ-POSE(WS-SLOT) TO WS-PREV-POSE
     END-PERFORM
     MOVE "acceptance US15 20§16.4 with the hurt_by memory the landing's jump cooldown is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE BZ-CD(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM SPAWN-BREEZE
     MOVE 0 TO WS-PREV-POSE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14 OR WS-PREV-POSE = 2
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         MOVE BZ-POSE(WS-SLOT) TO WS-PREV-POSE
     END-PERFORM
     MOVE 200 TO BZ-RUN(WS-SLOT)
     PERFORM STEP-MOB
     MOVE "acceptance US15 20§16.4 a flight that has run 200 ticks ends (STANDING, jump target gone)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-POSE(WS-SLOT) * 10 + BZ-JSET(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   A target exactly 24 blocks away is kept by the stop rule (counter 100) and by the targeting, but LongJump.canRun erases it (closerThan 24 is strict).
     MOVE 24 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     MOVE 100 TO EN-WAKE(WS-MOB)
     PERFORM STEP-MOB
     MOVE "acceptance US15 20§16.4 step 5: a target exactly 24 blocks away is not within the follow range: erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Step 7: standing in a honey block, or a block among the four above the breeze's block, rules the jump out.
     MOVE "minecraft:honey_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-HONEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE 10 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-MOB))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-MOB))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-MOB))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-HONEY
     PERFORM STEP-MOB
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§16.4 step 7: a breeze in a honey block does not jump" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-POSE(WS-SLOT) * 10 + BZ-JSET(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM SPAWN-BREEZE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-MOB))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-MOB)) + 3
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-MOB))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     PERFORM STEP-MOB
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§16.4 step 7: a stone block 3 above the breeze's block does not allow the jump" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-POSE(WS-SLOT) * 10 + BZ-JSET(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Step 10: a stone wall (9 high) between the breeze and its target blocks both sight lines: no inhale in 5 ticks.
     MOVE 10 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     COMPUTE WS-WALL-X = FUNCTION INTEGER(EN-X(WS-MOB)) + 5
     PERFORM VARYING WS-BZ FROM WS-FZ BY 1 UNTIL WS-BZ >= WS-FZ + WS-FSIZE
         PERFORM VARYING WS-BY FROM WS-FY BY 1 UNTIL WS-BY > WS-FY + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WALL-X WS-BY WS-BZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-SEEN-POSE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         PERFORM STEP-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
         IF BZ-POSE(WS-SLOT) = 1
             MOVE 1 TO WS-SEEN-POSE
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§16.4 step 10: with a wall in the line of sight the jump does not start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-BZ FROM WS-FZ BY 1 UNTIL WS-BZ >= WS-FZ + WS-FSIZE
         PERFORM VARYING WS-BY FROM WS-FY BY 1 UNTIL WS-BY > WS-FY + 12
             IF WS-BY = WS-FY
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WALL-X WS-BY WS-BZ WS-STONE
             ELSE
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WALL-X WS-BY WS-BZ WS-AIR
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   The walk target of a slide inside a solid block is not reachable: the cant-reach memory is set. The target is exactly 4 blocks away (too close for the jump, not within the inner circle), the layer
*>   above the floor is stone but for the breeze's cell.
     COMPUTE WS-K = WS-FY + 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-K WS-FKIND
     MOVE 4 TO WS-DISTANCE
     PERFORM SPAWN-BREEZE
     PERFORM STEP-MOB
     CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 16.1 a slide point inside a solid block is unreachable: cant_reach_walk_target_since is set" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BZ-WALK(WS-SLOT) * 10 + BZ-CANT-ON(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND

*>   All 16 slots hold live breezes: a 17th takes the first slot over.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 17
         COMPUTE WS-X0 = WS-X + 20 + WS-K
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         CALL "BZ-FIND" USING EN-ID(WS-MOB) WS-ONE WS-SLOT
     END-PERFORM
     MOVE "acceptance US15 20§16 the 17th live breeze takes slot 1 over" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The idle stroll goes at 0.6: the factor against the table speed is its square.
     MOVE "breeze" TO WS-KEY24
     CALL "STDMOB-STROLL-SCALE" USING WS-KEY24 WS-SCALE
     MOVE "acceptance US15 20§16.1 the breeze strolls at 0.6 (factor 0.36)" TO TL-CASE
     MOVE 360 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALE * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SPAWN-BREEZE.
     COMPUTE WS-X0 = WS-X - WS-DISTANCE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB).
 STEP-MOB.
     IF PL-HURT-COOLDOWN(WS-PLAYER) > 0
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     END-IF
     MOVE 30 TO PL-HEALTH(WS-PLAYER)
     ADD 1 TO CW-TICKS
     CALL "MOB-STEP" USING WS-MOB.
 END PROGRAM TEST-MOB-20-16-6.
 COPY CORETEST.
 COPY MOBSPTEST.
