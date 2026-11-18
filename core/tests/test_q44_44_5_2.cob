*> Crossbow and projectile-weapon arithmetic (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 2, worked examples 1 to 6 of section 9 and the checks 1 to 6 and 14 of
*> section 10; lane 002-lane-p49i, T22520; phase task T2736). Programs of core/src/q44-44-5.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-OUT                 FLOAT-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-CUR                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TABLE.
    05 WS-ENTRY            FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SIZE                BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 129 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-P4                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-DISCARD             BINARY-LONG.
 01 WS-STRUCK              BINARY-LONG.
 01 WS-D                   PIC 9.
 PROCEDURE DIVISION.
*>   2.1 level based values.
     MOVE 1 TO WS-KIND
     MOVE 4.5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 3 TO WS-LEVEL
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "constant level value is the constant" TO WS-CASE
     PERFORM CHECK-F-45
     MOVE 2 TO WS-KIND
     MOVE -0.25 TO WS-A
     MOVE -0.25 TO WS-B
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "linear level value at level 3 (quick charge: base -0.25, per level above the first -0.25) is -0.75" TO WS-CASE
     MOVE -7500 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-KIND
     MOVE 0.5 TO WS-A
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "levels_squared at level 3 with added 0.5 is 9.5" TO WS-CASE
     MOVE 95000 TO WS-E
     PERFORM CHECK-F
     MOVE 4 TO WS-KIND
     MOVE 2 TO WS-A
     MOVE 3 TO WS-B
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "exponent 2 ^ 3 is 8" TO WS-CASE
     MOVE 80000 TO WS-E
     PERFORM CHECK-F
     MOVE 5 TO WS-KIND
     MOVE 3 TO WS-A
     MOVE 4 TO WS-B
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "fraction 3 / 4 is 0.75" TO WS-CASE
     MOVE 7500 TO WS-E
     PERFORM CHECK-F
     MOVE 0 TO WS-B
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "fraction with denominator 0 is 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 99 TO WS-KIND
     CALL "Q5-LEVEL-VALUE" USING WS-KIND WS-A WS-B WS-LEVEL WS-OUT
     MOVE "an unknown kind is 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 5 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "Q5-CLAMP-VALUE" USING WS-X WS-Y WS-Z WS-OUT
     MOVE "clamped: 5 within 0 to 3 is 3" TO WS-CASE
     MOVE 30000 TO WS-E
     PERFORM CHECK-F
     MOVE -1 TO WS-X
     CALL "Q5-CLAMP-VALUE" USING WS-X WS-Y WS-Z WS-OUT
     MOVE "clamped: -1 within 0 to 3 is 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-X
     CALL "Q5-CLAMP-VALUE" USING WS-X WS-Y WS-Z WS-OUT
     MOVE "clamped: 2 within 0 to 3 stays 2" TO WS-CASE
     MOVE 20000 TO WS-E
     PERFORM CHECK-F
     MOVE 1.5 TO WS-ENTRY(1)
     MOVE 2.5 TO WS-ENTRY(2)
     MOVE 2 TO WS-SIZE
     MOVE 7 TO WS-A
     MOVE 2 TO WS-LEVEL
     CALL "Q5-LOOKUP-VALUE" USING WS-TABLE WS-SIZE WS-A WS-LEVEL WS-OUT
     MOVE "lookup at level 2 reads the second value (one-based)" TO WS-CASE
     MOVE 25000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-LEVEL
     CALL "Q5-LOOKUP-VALUE" USING WS-TABLE WS-SIZE WS-A WS-LEVEL WS-OUT
     MOVE "lookup above the list takes the fallback" TO WS-CASE
     MOVE 70000 TO WS-E
     PERFORM CHECK-F
*>   2.1 value effects.
     MOVE 2 TO WS-CUR
     MOVE 3 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 1 TO WS-OP
     CALL "Q5-VALUE-EFFECT" USING WS-OP WS-X WS-Y WS-CUR WS-OUT
     MOVE "add: current + value" TO WS-CASE
     MOVE 50000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-OP
     CALL "Q5-VALUE-EFFECT" USING WS-OP WS-X WS-Y WS-CUR WS-OUT
     MOVE "multiply: current x factor" TO WS-CASE
     MOVE 60000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-OP
     CALL "Q5-VALUE-EFFECT" USING WS-OP WS-X WS-Y WS-CUR WS-OUT
     MOVE "set: ignores the current value" TO WS-CASE
     MOVE 30000 TO WS-E
     PERFORM CHECK-F
     MOVE 4 TO WS-OP
     CALL "Q5-VALUE-EFFECT" USING WS-OP WS-X WS-Y WS-CUR WS-OUT
     MOVE "scale_exponentially: current x base ^ exponent (2 x 3 ^ 2 = 18)" TO WS-CASE
     MOVE 180000 TO WS-E
     PERFORM CHECK-F
     MOVE 9 TO WS-OP
     CALL "Q5-VALUE-EFFECT" USING WS-OP WS-X WS-Y WS-CUR WS-OUT
     MOVE "an unknown operation leaves the current value" TO WS-CASE
     MOVE 20000 TO WS-E
     PERFORM CHECK-F
*>   remove_binomial: small branch, one draw per iteration.
     MOVE 0.1 TO WS-DRAW(1)
     MOVE 0.6 TO WS-DRAW(2)
     MOVE 0.4 TO WS-DRAW(3)
     MOVE 0.9 TO WS-DRAW(4)
     MOVE 0.2 TO WS-DRAW(5)
     MOVE 5 TO WS-X
     MOVE 0.5 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "Q5-REMOVE-BINOMIAL" USING WS-X WS-Y WS-DRAWS WS-Z WS-OUT
     MOVE "remove_binomial small branch: c 5, p 0.5, draws .1 .6 .4 .9 .2 count 3 gives 2" TO WS-CASE
     MOVE 20000 TO WS-E
     PERFORM CHECK-F
     MOVE 2.5 TO WS-X
     MOVE 0.1 TO WS-DRAW(1)
     MOVE 0.1 TO WS-DRAW(2)
     MOVE 0.1 TO WS-DRAW(3)
     CALL "Q5-REMOVE-BINOMIAL" USING WS-X WS-Y WS-DRAWS WS-Z WS-OUT
     MOVE "remove_binomial small branch: c 2.5 runs three iterations (i < c), all below p: -0.5" TO WS-CASE
     MOVE -5000 TO WS-E
     PERFORM CHECK-F
     MOVE 1000 TO WS-X
     MOVE 1 TO WS-Z
     CALL "Q5-REMOVE-BINOMIAL" USING WS-X WS-Y WS-DRAWS WS-Z WS-OUT
     MOVE "remove_binomial large branch: c 1000, p 0.5, gaussian 1: mean 500, sd 15.81, count 516, gives 484" TO WS-CASE
     MOVE 4840000 TO WS-E
     PERFORM CHECK-F
     MOVE 1000 TO WS-Z
     CALL "Q5-REMOVE-BINOMIAL" USING WS-X WS-Y WS-DRAWS WS-Z WS-OUT
     MOVE "remove_binomial large branch: the count is clamped to int(c): 0 left" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE -1000 TO WS-Z
     CALL "Q5-REMOVE-BINOMIAL" USING WS-X WS-Y WS-DRAWS WS-Z WS-OUT
     MOVE "remove_binomial large branch: the count is clamped at 0: 1000 left" TO WS-CASE
     MOVE 10000000 TO WS-E
     PERFORM CHECK-F
*>   The clamps after the walk.
     MOVE 1 TO WS-KIND
     MOVE 3.9 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "projectile count 3.9 is 3 (truncated)" TO WS-CASE
     MOVE 30000 TO WS-E
     PERFORM CHECK-F
     MOVE -1.2 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "projectile count -1.2 is 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-KIND
     MOVE 2.9 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "piercing count 2.9 is 2" TO WS-CASE
     MOVE 20000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-KIND
     MOVE -2 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "spread -2 is 0.0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 10 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "spread 10 stays 10" TO WS-CASE
     MOVE 100000 TO WS-E
     PERFORM CHECK-F
     MOVE 4 TO WS-KIND
     MOVE -0.25 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "charge time -0.25 is 0.0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 5 TO WS-KIND
     MOVE -1.5 TO WS-X
     CALL "Q5-RESULT" USING WS-KIND WS-X WS-OUT
     MOVE "ammo use is int(value) with no lower clamp: -1.5 is -1" TO WS-CASE
     MOVE -10000 TO WS-E
     PERFORM CHECK-F
*>   2.3 charge duration (worked example 1, check 1).
     PERFORM VARYING WS-LEVEL FROM 0 BY 1 UNTIL WS-LEVEL > 3
         CALL "Q5-CHARGE-TICKS" USING WS-LEVEL WS-T
         COMPUTE WS-E = 25 - 5 * WS-LEVEL
         MOVE WS-T TO WS-O
         MOVE SPACES TO WS-CASE
         MOVE WS-LEVEL TO WS-D
         STRING "charge duration at Quick Charge " DELIMITED BY SIZE WS-D DELIMITED BY SIZE " is 25 - 5 level ticks" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-N
     END-PERFORM
     MOVE 5 TO WS-LEVEL
     CALL "Q5-CHARGE-TICKS" USING WS-LEVEL WS-T
     MOVE "charge duration at Quick Charge 5 is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-T TO WS-O
     PERFORM CHECK-N
     MOVE 6 TO WS-LEVEL
     CALL "Q5-CHARGE-TICKS" USING WS-LEVEL WS-T
     MOVE "charge duration at Quick Charge 6 (-0.25 seconds) is clamped to 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-T TO WS-O
     PERFORM CHECK-N
*>   2.3 step 3: the phases of onUseTick for a charge duration of 20.
     MOVE 20 TO WS-T
     MOVE 3 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P1
     MOVE 4 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P2
     MOVE 10 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P3
     MOVE 20 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P4
     MOVE "charge phases of a 20 tick charge: 3 ticks none, 4 start sound, 10 middle sound, 20 loaded" TO WS-CASE
     COMPUTE WS-E = 0 * 1000 + 1 * 100 + 2 * 10 + 3
     COMPUTE WS-O = WS-P1 * 1000 + WS-P2 * 100 + WS-P3 * 10 + WS-P4
     PERFORM CHECK-N
     MOVE 9 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P1
     MOVE 19 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P2
     MOVE "charge phases: 9 ticks is still the start sound (0.45), 19 the middle sound" TO WS-CASE
     MOVE 12 TO WS-E
     COMPUTE WS-O = WS-P1 * 10 + WS-P2
     PERFORM CHECK-N
     MOVE 0 TO WS-T
     MOVE 0 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P1
     MOVE 1 TO WS-I
     CALL "Q5-CHARGE-PHASE" USING WS-I WS-T WS-P2
     MOVE "a duration 0 crossbow does nothing at elapsed 0 (NaN) and loads from elapsed 1 (infinity)" TO WS-CASE
     MOVE 3 TO WS-E
     COMPUTE WS-O = WS-P1 * 10 + WS-P2
     PERFORM CHECK-N
*>   2.4 draw.
     MOVE 3 TO WS-X
     MOVE 1 TO WS-I
     CALL "Q5-DRAW-COUNT" USING WS-X WS-I WS-N
     MOVE "draw with Multishot: three projectiles on a server" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     CALL "Q5-DRAW-COUNT" USING WS-X WS-I WS-N
     MOVE "draw off a server level: one projectile whatever the enchantment" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE -2 TO WS-X
     MOVE 1 TO WS-I
     CALL "Q5-DRAW-COUNT" USING WS-X WS-I WS-N
     MOVE "draw: a negative count value gives no projectile" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   useAmmo (worked example 3, check 2): fire 3 arrows from a stack of 5.
     MOVE 0 TO WS-P1
     MOVE 0 TO WS-P2
     MOVE 1 TO WS-I
     MOVE 1 TO WS-T
     MOVE 5 TO WS-N
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: the first projectile takes one arrow from the stack" TO WS-CASE
     MOVE 21 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
     MOVE 1 TO WS-P1
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: a later projectile (forced free) is an intangible copy and takes nothing" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
     MOVE 0 TO WS-P1
     MOVE 1 TO WS-P2
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: a creative shooter (infinite materials) takes nothing: intangible copy" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
     MOVE 0 TO WS-P2
     MOVE 0 TO WS-I
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: off a server level the cost is 0" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     MOVE 0 TO WS-T
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: an ammo_use effect that sets 0 (Infinity) takes nothing" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
     MOVE 2 TO WS-T
     MOVE 1 TO WS-N
     CALL "Q5-USE-AMMO" USING WS-P1 WS-P2 WS-I WS-T WS-N WS-RES WS-TAKEN
     MOVE "useAmmo: a cost above the stack count gives the empty result" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-RES * 10 + WS-TAKEN
     PERFORM CHECK-N
*>   2.5 shoot angles (worked example 2, check 2).
     MOVE 10 TO WS-X
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         MOVE 3 TO WS-N
         CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
         EVALUATE WS-I
             WHEN 0
                 MOVE 0 TO WS-E
             WHEN 1
                 MOVE -100000 TO WS-E
             WHEN OTHER
                 MOVE 100000 TO WS-E
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-D
         STRING "Multishot n 3 spread 10: angle of projectile " DELIMITED BY SIZE WS-D DELIMITED BY SIZE " is 0, -10, +10" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-F
     END-PERFORM
     MOVE 2 TO WS-N
     MOVE 0 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 2 spread 10: the first angle is +10" TO WS-CASE
     MOVE 100000 TO WS-E
     PERFORM CHECK-F
     MOVE 1 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 2 spread 10: the second angle is -10" TO WS-CASE
     MOVE -100000 TO WS-E
     PERFORM CHECK-F
     MOVE 4 TO WS-N
     MOVE 0 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 4 spread 10: projectile 0 is S/3" TO WS-CASE
     MOVE 33333 TO WS-E
     PERFORM CHECK-F
     MOVE 1 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 4 spread 10: projectile 1 is -S/3" TO WS-CASE
     MOVE -33333 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 4 spread 10: projectile 2 is +S" TO WS-CASE
     MOVE 100000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 4 spread 10: projectile 3 is -S" TO WS-CASE
     MOVE -100000 TO WS-E
     PERFORM CHECK-F
     MOVE 1 TO WS-N
     MOVE 0 TO WS-I
     CALL "Q5-SHOOT-ANGLE" USING WS-N WS-X WS-I WS-OUT
     MOVE "n 1: the angle is 0 whatever the spread" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
*>   2.6 shot pitch (worked example 6, check 6).
     MOVE 0 TO WS-I
     MOVE 0.5 TO WS-X
     CALL "Q5-SHOT-PITCH" USING WS-I WS-X WS-OUT
     MOVE "shot pitch of index 0 is exactly 1.0" TO WS-CASE
     MOVE 10000 TO WS-E
     PERFORM CHECK-F-4
     MOVE 1 TO WS-I
     CALL "Q5-SHOT-PITCH" USING WS-I WS-X WS-OUT
     MOVE "shot pitch of index 1 with r 0.5 is 0.63 + 1 / 2.05 = 1.1178" TO WS-CASE
     MOVE 11178 TO WS-E
     PERFORM CHECK-F-4
     MOVE 2 TO WS-I
     CALL "Q5-SHOT-PITCH" USING WS-I WS-X WS-OUT
     MOVE "shot pitch of index 2 with r 0.5 is 0.43 + 0.4878 = 0.9178" TO WS-CASE
     MOVE 9178 TO WS-E
     PERFORM CHECK-F-4
*>   Power and durability (check 14).
     MOVE 1 TO WS-P1
     MOVE 0 TO WS-P2
     CALL "Q5-CROSSBOW-POWER" USING WS-P1 WS-P2 WS-OUT WS-T
     MOVE "a player's crossbow fires at 3.15 and costs 1 durability" TO WS-CASE
     MOVE 31500 TO WS-E
     PERFORM CHECK-F-4
     MOVE WS-T TO WS-O
     MOVE 1 TO WS-E
     MOVE "a player's crossbow shot costs 1 durability" TO WS-CASE
     PERFORM CHECK-N
     MOVE 1 TO WS-P2
     CALL "Q5-CROSSBOW-POWER" USING WS-P1 WS-P2 WS-OUT WS-T
     MOVE "a player's crossbow with a firework rocket fires at 1.6" TO WS-CASE
     MOVE 16000 TO WS-E
     PERFORM CHECK-F-4
     MOVE WS-T TO WS-O
     MOVE 3 TO WS-E
     MOVE "a firework rocket shot costs 3 durability" TO WS-CASE
     PERFORM CHECK-N
     MOVE 0 TO WS-P1
     MOVE 0 TO WS-P2
     CALL "Q5-CROSSBOW-POWER" USING WS-P1 WS-P2 WS-OUT WS-T
     MOVE "a mob's crossbow shot uses power 1.6 (MOB_ARROW_POWER)" TO WS-CASE
     MOVE 16000 TO WS-E
     PERFORM CHECK-F-4
*>   Monster ammunition (check 4).
     MOVE 1 TO WS-P1
     MOVE 1 TO WS-P2
     CALL "Q5-MONSTER-AMMO" USING WS-P1 WS-P2 WS-RES
     MOVE "monster ammunition: the off-hand stack comes first" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-P1
     CALL "Q5-MONSTER-AMMO" USING WS-P1 WS-P2 WS-RES
     MOVE "monster ammunition: the main-hand stack when the off hand does not fit" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-P2
     CALL "Q5-MONSTER-AMMO" USING WS-P1 WS-P2 WS-RES
     MOVE "monster ammunition: with nothing held a fresh arrow every shot" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
*>   Crit rule.
     MOVE 1 TO WS-P1
     CALL "Q5-CROSSBOW-CRIT" USING WS-P1 WS-RES
     MOVE "arrows from a player's crossbow are crit arrows" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-P1
     CALL "Q5-CROSSBOW-CRIT" USING WS-P1 WS-RES
     MOVE "arrows from a pillager or piglin are not crit arrows" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
*>   2.7 piercing (worked example 4, check 5): Piercing 2 damages three entities.
     MOVE 0 TO WS-STRUCK
     MOVE 0 TO WS-N
     PERFORM 5 TIMES
         MOVE 2 TO WS-LEVEL
         CALL "Q5-PIERCE-HIT" USING WS-LEVEL WS-STRUCK WS-HIT WS-DISCARD
         ADD WS-HIT TO WS-N
     END-PERFORM
     MOVE "an arrow with pierce level 2 damages exactly 3 entities of 5 in a line" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "the fourth entity gets no hit and the arrow is discarded" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-HIT * 10 + WS-DISCARD
     PERFORM CHECK-N
     MOVE 0 TO WS-STRUCK
     MOVE 2 TO WS-LEVEL
     CALL "Q5-PIERCE-HIT" USING WS-LEVEL WS-STRUCK WS-HIT WS-DISCARD
     MOVE "a piercing arrow that struck one entity is not discarded" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-HIT * 10 + WS-DISCARD
     PERFORM CHECK-N
     MOVE 0 TO WS-LEVEL
     CALL "Q5-PIERCE-HIT" USING WS-LEVEL WS-STRUCK WS-HIT WS-DISCARD
     MOVE "an arrow without piercing hits once and is discarded" TO WS-CASE
     MOVE 11 TO WS-E
     COMPUTE WS-O = WS-HIT * 10 + WS-DISCARD
     PERFORM CHECK-N
*>   Damage (worked example 5).
     MOVE 3.15 TO WS-X
     MOVE 2.0 TO WS-Y
     CALL "Q5-ARROW-DAMAGE" USING WS-X WS-Y WS-N
     MOVE "arrow damage ceil(3.15 x 2.0) is 7" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     CALL "Q5-CRIT-BOUND" USING WS-N WS-T
     MOVE "a crit arrow of damage 7 adds nextInt(5): the final damage is 7 to 11" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-T TO WS-O
     PERFORM CHECK-N
     MOVE -1 TO WS-X
     CALL "Q5-ARROW-DAMAGE" USING WS-X WS-Y WS-N
     MOVE "arrow damage is clamped below at 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE 2000000000 TO WS-X
     MOVE 5 TO WS-Y
     CALL "Q5-ARROW-DAMAGE" USING WS-X WS-Y WS-N
     MOVE "arrow damage is clamped above at 2147483647" TO WS-CASE
     MOVE 2147483647 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   2.6 aim: dy = target.getY(1/3) - projectile.y + h x 0.2.
     MOVE 65.62 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 10 TO WS-Z
     CALL "Q5-AIM-DY" USING WS-X WS-Y WS-Z WS-OUT
     MOVE "a mob's aim: dy = 0.62 + 10 x 0.2 = 2.62" TO WS-CASE
     MOVE 26200 TO WS-E
     PERFORM CHECK-F-4
*>   The older tools programs (17 section 3.9) agree with the corrected rules.
     MOVE 5 TO WS-I
     CALL "TOOL-CROSSBOW-CHARGE" USING WS-I WS-T
     MOVE "TOOL-CROSSBOW-CHARGE at Quick Charge 5 is clamped to 0 ticks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-T TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     MOVE 0 TO WS-I
     CALL "TOOL-CROSSBOW-ANGLE" USING WS-N WS-I WS-T
     MOVE 1 TO WS-I
     CALL "TOOL-CROSSBOW-ANGLE" USING WS-N WS-I WS-RES
     MOVE "TOOL-CROSSBOW-ANGLE for n 2 is +10 then -10" TO WS-CASE
     MOVE 1 TO WS-E
     IF WS-T = 10 AND WS-RES = -10
         MOVE 1 TO WS-O
     ELSE
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     MOVE 0 TO WS-T
     CALL "TOOL-CROSSBOW-READY" USING WS-I WS-T WS-RES
     MOVE "TOOL-CROSSBOW-READY: a duration 0 crossbow does not load at elapsed 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     CALL "TOOL-CROSSBOW-READY" USING WS-I WS-T WS-RES
     MOVE "TOOL-CROSSBOW-READY: a duration 0 crossbow loads from elapsed 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-F-45.
     MOVE 45000 TO WS-E
     PERFORM CHECK-F.

*> CHECK-F: WS-OUT x 10000 rounded against WS-E (the expectation is in ten thousandths).
 CHECK-F.
     COMPUTE WS-O ROUNDED = WS-OUT * 10000
     PERFORM CHECK-N.

 CHECK-F-4.
     COMPUTE WS-O ROUNDED = WS-OUT * 10000
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     STRING "acceptance US15 44-5§2 Crossbow and projectile-weapon arithmetic: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-5-2.
