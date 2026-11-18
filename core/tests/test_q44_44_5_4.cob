*> Sulfur cube movement attributes (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 4, worked examples of 4.4 and example 11 of section 9, checks 9, 13 and 14 of
*> section 10; lane 002-lane-p49i, T22540; phase task T2740). Programs of core/src/q44-44-5.cob. Floats are compared in millionths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-BLOCK               FLOAT-LONG.
 01 WS-FRIC                FLOAT-LONG.
 01 WS-AIR                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-REQ                 FLOAT-LONG.
 01 WS-GRAV                FLOAT-LONG.
 01 WS-DRAG                FLOAT-LONG.
 01 WS-BB                  FLOAT-LONG.
 01 WS-ATTR                FLOAT-LONG.
 01 WS-BOUNCED             BINARY-LONG.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 2.
 01 WS-L0B                 BINARY-LONG VALUE 0.
 01 WS-L0C                 BINARY-LONG VALUE 0.
 01 WS-L0D                 BINARY-LONG VALUE 0.
 01 WS-L0E                 BINARY-LONG VALUE 0.
 01 WS-L1B                 BINARY-LONG VALUE 1.
 01 WS-L1C                 BINARY-LONG VALUE 1.
 01 WS-L1D                 BINARY-LONG VALUE 1.
 01 WS-L1E                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
*>   The attribute ranges and the modifier arithmetic.
     MOVE -0.699999988079071 TO WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "a lone add_multiplied_total amount -0.7 on base 1 gives 0.3" TO WS-CASE
     MOVE 300000 TO WS-E
     PERFORM CHECK-F
     MOVE -10 TO WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "the value is clamped below at 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 5000 TO WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "the value is clamped above at 2048" TO WS-CASE
     MOVE 2048000000 TO WS-E
     PERFORM CHECK-F
*>   computeModifiedFriction (check 9).
     MOVE 0.6 TO WS-A
     MOVE 0.3 TO WS-B
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE "computeModifiedFriction(0.6, 0.3) = 0.88" TO WS-CASE
     MOVE 880000 TO WS-E
     PERFORM CHECK-F
     MOVE 2.0 TO WS-B
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE "computeModifiedFriction(0.6, 2.0) = 0.2" TO WS-CASE
     MOVE 200000 TO WS-E
     PERFORM CHECK-F
     MOVE 10 TO WS-B
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE "computeModifiedFriction(0.6, 10) is clamped to 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 0.91 TO WS-A
     MOVE 0.1 TO WS-B
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE "computeModifiedFriction(0.91, 0.1) = 0.991" TO WS-CASE
     MOVE 991000 TO WS-E
     PERFORM CHECK-F
     MOVE 0 TO WS-B
     MOVE 1.5 TO WS-A
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE "computeModifiedFriction is clamped above at 1 (base 1.5, modifier 1.0)" TO WS-CASE
     MOVE 1.0 TO WS-B
     CALL "Q5-MOD-FRICTION" USING WS-A WS-B WS-OUT
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
*>   The archetype values from the JSON (regular, sticky, light).
     MOVE 1 TO WS-I
     MOVE 1 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "regular: friction_modifier 0.3" TO WS-CASE
     MOVE 300000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "regular: air_drag_modifier 0.1 (0.1000000015 stored)" TO WS-CASE
     MOVE 100000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "regular: bounciness 0.5" TO WS-CASE
     MOVE 500000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-I
     MOVE 1 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "sticky: friction_modifier 2.0" TO WS-CASE
     MOVE 2000000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "sticky: air_drag_modifier 0.01" TO WS-CASE
     MOVE 10000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "sticky: bounciness 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-I
     MOVE 2 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-A
     CALL "Q5-MODIFIED-VALUE" USING WS-A WS-OUT
     MOVE "light: air_drag_modifier 1.8" TO WS-CASE
     MOVE 1800000 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "light: bounciness 1.0" TO WS-CASE
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
     MOVE 4 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "light: knockback_resistance -1.0" TO WS-CASE
     MOVE -1000000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-I
     MOVE 5 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "sticky: explosion_knockback_resistance -2.0" TO WS-CASE
     MOVE -2000000 TO WS-E
     PERFORM CHECK-F
     MOVE 6 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "sticky: not buoyant" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 1 TO WS-I
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "regular: buoyant" TO WS-CASE
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
     MOVE 7 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "regular: horizontal_power 0.4125" TO WS-CASE
     MOVE 412500 TO WS-E
     PERFORM CHECK-F
     MOVE 3 TO WS-I
     MOVE 8 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "light: vertical_power 0.18" TO WS-CASE
     MOVE 180000 TO WS-E
     PERFORM CHECK-F
     MOVE 9 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "light: push_sound_cooldown 0.7" TO WS-CASE
     MOVE 700000 TO WS-E
     PERFORM CHECK-F
     MOVE 2 TO WS-I
     MOVE 10 TO WS-N
     CALL "Q5-ARCH-FIELD" USING WS-I WS-N WS-OUT
     MOVE "sticky: push_sound_impulse_threshold 0.05" TO WS-CASE
     MOVE 50000 TO WS-E
     PERFORM CHECK-F
*>   4.4 worked examples: f, H, V on block friction 0.6.
     MOVE 0.6 TO WS-BLOCK
     MOVE 0.3 TO WS-FRIC
     MOVE 0.1 TO WS-AIR
     CALL "Q5-GROUND" USING WS-BLOCK WS-FRIC WS-AIR WS-L1 WS-L0 WS-F WS-H WS-V WS-S
     MOVE "regular on the ground: f = 0.88" TO WS-CASE
     MOVE WS-F TO WS-OUT
     MOVE 880000 TO WS-E
     PERFORM CHECK-F
     MOVE "regular: H = 0.88 x 0.991 = 0.87208" TO WS-CASE
     MOVE WS-H TO WS-OUT
     MOVE 872080 TO WS-E
     PERFORM CHECK-F
     MOVE "regular: V (non-omni) = 0.998" TO WS-CASE
     MOVE WS-V TO WS-OUT
     MOVE 998000 TO WS-E
     PERFORM CHECK-F
     MOVE "regular: the speed input is multiplied by 0.216 / 0.88^3 = 0.3170" TO WS-CASE
     MOVE WS-S TO WS-OUT
     MOVE 317000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-OUT * 10000
     COMPUTE WS-O = WS-O * 100
     MOVE 317000 TO WS-E
     PERFORM CHECK-N
     MOVE 2.0 TO WS-FRIC
     MOVE 0.01 TO WS-AIR
     CALL "Q5-GROUND" USING WS-BLOCK WS-FRIC WS-AIR WS-L1 WS-L0 WS-F WS-H WS-V WS-S
     MOVE "sticky: f = 0.2" TO WS-CASE
     MOVE WS-F TO WS-OUT
     MOVE 200000 TO WS-E
     PERFORM CHECK-F
     MOVE "sticky: H = 0.2 x 0.9991 = 0.19982" TO WS-CASE
     MOVE WS-H TO WS-OUT
     MOVE 199820 TO WS-E
     PERFORM CHECK-F
     MOVE "sticky: V = 0.9998" TO WS-CASE
     MOVE WS-V TO WS-OUT
     MOVE 999800 TO WS-E
     PERFORM CHECK-F
     MOVE "sticky: f <= 0.6 leaves the speed input as it is" TO WS-CASE
     MOVE WS-S TO WS-OUT
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
     MOVE 0.3 TO WS-FRIC
     MOVE 1.8 TO WS-AIR
     CALL "Q5-GROUND" USING WS-BLOCK WS-FRIC WS-AIR WS-L1 WS-L0 WS-F WS-H WS-V WS-S
     MOVE "light: H = 0.88 x 0.838 = 0.73744" TO WS-CASE
     MOVE WS-H TO WS-OUT
     MOVE 737440 TO WS-E
     PERFORM CHECK-F
     MOVE "light: V = 0.964" TO WS-CASE
     MOVE WS-V TO WS-OUT
     MOVE 964000 TO WS-E
     PERFORM CHECK-F
     MOVE 1.0 TO WS-FRIC
     MOVE 1.0 TO WS-AIR
     CALL "Q5-GROUND" USING WS-BLOCK WS-FRIC WS-AIR WS-L1 WS-L0 WS-F WS-H WS-V WS-S
     MOVE "plain entity on block friction 0.6: f 0.6, H 0.546" TO WS-CASE
     MOVE WS-H TO WS-OUT
     MOVE 546000 TO WS-E
     PERFORM CHECK-F
     MOVE "plain entity: V 0.98" TO WS-CASE
     MOVE WS-V TO WS-OUT
     MOVE 980000 TO WS-E
     PERFORM CHECK-F
     MOVE "plain entity: f = 0.6 is not above 0.6, the speed input stays" TO WS-CASE
     MOVE WS-S TO WS-OUT
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
     CALL "Q5-GROUND" USING WS-BLOCK WS-FRIC WS-AIR WS-L0 WS-L1 WS-F WS-H WS-V WS-S
     MOVE "in the air f is 1.0 and an omnidirectional mover has V 0.91" TO WS-CASE
     MOVE WS-V TO WS-OUT
     MOVE 910000 TO WS-E
     PERFORM CHECK-F
     MOVE "in the air the horizontal factor is 0.91" TO WS-CASE
     MOVE WS-H TO WS-OUT
     MOVE 910000 TO WS-E
     PERFORM CHECK-F
*>   Gravity (check 13): on a server always, a client without the chunk uses -0.1 above the minimum Y, else 0.
     MOVE -0.2 TO WS-A
     MOVE 0.08 TO WS-B
     CALL "Q5-FALL-Y" USING WS-A WS-B WS-L0 WS-L0B WS-L0C WS-OUT
     MOVE "on a server gravity always applies (no chunk test): -0.2 - 0.08 = -0.28" TO WS-CASE
     MOVE -280000 TO WS-E
     PERFORM CHECK-F
     CALL "Q5-FALL-Y" USING WS-A WS-B WS-L1 WS-L1B WS-L0 WS-OUT
     MOVE "a client with its chunk loaded subtracts gravity" TO WS-CASE
     MOVE -280000 TO WS-E
     PERFORM CHECK-F
     CALL "Q5-FALL-Y" USING WS-A WS-B WS-L1 WS-L0 WS-L1B WS-OUT
     MOVE "a client without the chunk above the minimum Y uses -0.1" TO WS-CASE
     MOVE -100000 TO WS-E
     PERFORM CHECK-F
     CALL "Q5-FALL-Y" USING WS-A WS-B WS-L1 WS-L0 WS-L0B WS-OUT
     MOVE "a client without the chunk at the minimum Y uses 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 0 TO WS-A
     CALL "Q5-LEVITATE" USING WS-A WS-L0 WS-OUT
     MOVE "Levitation amplifier 0 from rest: y += (0.05 - 0) x 0.2 = 0.01" TO WS-CASE
     MOVE 10000 TO WS-E
     PERFORM CHECK-F
*>   Blocks: restitution and the suppresses_bounce tag.
     MOVE "slime_block" TO WS-KEY
     CALL "Q5-BLOCK-RESTITUTION" USING WS-KEY WS-OUT
     MOVE "slime_block bounce_restitution 1.0" TO WS-CASE
     MOVE 1000000 TO WS-E
     PERFORM CHECK-F
     MOVE "red_bed" TO WS-KEY
     CALL "Q5-BLOCK-RESTITUTION" USING WS-KEY WS-OUT
     MOVE "a bed (red_bed) has 0.75" TO WS-CASE
     MOVE 750000 TO WS-E
     PERFORM CHECK-F
     MOVE "shelf_mushroom" TO WS-KEY
     CALL "Q5-BLOCK-RESTITUTION" USING WS-KEY WS-OUT
     MOVE "shelf_mushroom has 0.75" TO WS-CASE
     MOVE 750000 TO WS-E
     PERFORM CHECK-F
     MOVE "stone" TO WS-KEY
     CALL "Q5-BLOCK-RESTITUTION" USING WS-KEY WS-OUT
     MOVE "stone has the default 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE "bed" TO WS-KEY
     CALL "Q5-BLOCK-RESTITUTION" USING WS-KEY WS-OUT
     MOVE "a key without the _bed suffix ('bed' alone) has 0" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE "honey_block" TO WS-KEY
     CALL "Q5-SUPPRESSES-BOUNCE" USING WS-KEY WS-N
     MOVE "honey_block suppresses bounce" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "slime_block" TO WS-KEY
     CALL "Q5-SUPPRESSES-BOUNCE" USING WS-KEY WS-N
     MOVE "slime_block does not suppress bounce" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   Bounce (4.3).
     MOVE 0.08 TO WS-GRAV
     MOVE 0.98 TO WS-DRAG
     MOVE 0.5 TO WS-ATTR
     MOVE 0.2 TO WS-VX
     MOVE -0.6 TO WS-VY
     MOVE 0.1 TO WS-VZ
     MOVE -0.6 TO WS-REQ
     MOVE 0 TO WS-BB
*>   A regular cube (bounciness 0.5) lands on stone: no block bounciness, the entity's 0.5 applies. r = 1.
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L1 WS-L0C WS-L0D WS-BB WS-L1B WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a regular cube (0.5) landing at speed 0.6: (r gravity - vy) x lerp(r, 1, drag) x 0.5 = (0.08 + 0.6) x 0.98 x 0.5 = 0.3332" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 333200 TO WS-E
     PERFORM CHECK-F
     MOVE "a vertical bounce sets the bounced flag and leaves the horizontal velocity" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-BOUNCED TO WS-O
     PERFORM CHECK-N
     MOVE WS-NX TO WS-OUT
     MOVE "no horizontal collision keeps vx" TO WS-CASE
     MOVE 200000 TO WS-E
     PERFORM CHECK-F
*>   Slow fall: the downward speed does not exceed gravity: no bounce, the vertical velocity is 0.
     MOVE -0.05 TO WS-VY
     MOVE -0.05 TO WS-REQ
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L1 WS-L0C WS-L0D WS-BB WS-L1B WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a landing no faster than gravity does not bounce: vy becomes 0" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 0 TO WS-E
     PERFORM CHECK-F
     MOVE 0 TO WS-E
     MOVE WS-BOUNCED TO WS-O
     MOVE "and sets no bounce flag" TO WS-CASE
     PERFORM CHECK-N
*>   Sneaking: b = 0 whatever the attribute.
     MOVE -0.6 TO WS-VY
     MOVE -0.6 TO WS-REQ
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L1 WS-L1B WS-L1C WS-L1D WS-L0 WS-BB WS-L1E WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "sneaking: collided horizontal axes become -v x 0 = 0" TO WS-CASE
     MOVE WS-NX TO WS-OUT
     MOVE 0 TO WS-E
     PERFORM CHECK-F
*>   The honey block (suppresses bounce) on a floor hit.
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L1 WS-L0C WS-L1B WS-BB WS-L1C WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "honey_block below: the vertical factor is 0, vy becomes 0" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 0 TO WS-E
     PERFORM CHECK-F
*>   A horizontal collision of a bouncy entity reverses and scales the axis and flags the bounce.
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L1 WS-L0 WS-L0B WS-L0C WS-L0D WS-BB WS-L1B WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a horizontal collision of the regular cube: vx 0.2 becomes -0.1" TO WS-CASE
     MOVE WS-NX TO WS-OUT
     MOVE -100000 TO WS-E
     PERFORM CHECK-F
     MOVE "that collision sets the bounced flag" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-BOUNCED TO WS-O
     PERFORM CHECK-N
     MOVE "z without collision is unchanged" TO WS-CASE
     MOVE WS-NZ TO WS-OUT
     MOVE 100000 TO WS-E
     PERFORM CHECK-F
     MOVE "vy without a vertical collision is unchanged" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE -600000 TO WS-E
     PERFORM CHECK-F
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L1 WS-L0B WS-L0C WS-L0D WS-BB WS-L1B WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a z collision: vz 0.1 becomes -0.05" TO WS-CASE
     MOVE WS-NZ TO WS-OUT
     MOVE -50000 TO WS-E
     PERFORM CHECK-F
*>   A ceiling hit: the factor is b with no block term.
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L2 WS-L0C WS-L0D WS-BB WS-L1 WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a ceiling hit by the regular cube: (0.08 + 0.6) x 0.98 x 0.5" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 333200 TO WS-E
     PERFORM CHECK-F
*>   A non-living entity on a slime block: restitution 1.0 x 0.8.
     MOVE 0 TO WS-ATTR
     MOVE 1.0 TO WS-BB
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L1 WS-L0C WS-L0D WS-BB WS-L0E WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a non-living entity on a slime block: factor 1.0 x 0.8: 0.68 x 0.98 x 0.8 = 0.53312" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 533120 TO WS-E
     PERFORM CHECK-F
*>   A living entity with bounciness 0 on a slime block: max(b, 1.0).
     CALL "Q5-BOUNCE" USING WS-VX WS-VY WS-VZ WS-L0 WS-L0B WS-L1 WS-L0C WS-L0D WS-BB WS-L1B WS-ATTR WS-GRAV WS-REQ WS-DRAG
         WS-NX WS-NY WS-NZ WS-BOUNCED
     MOVE "a living entity on a slime block: factor max(0, 1.0): 0.68 x 0.98 = 0.6664" TO WS-CASE
     MOVE WS-NY TO WS-OUT
     MOVE 666400 TO WS-E
     PERFORM CHECK-F
     STOP RUN.

*> CHECK-F: WS-OUT in millionths against WS-E.
 CHECK-F.
     COMPUTE WS-O ROUNDED = WS-OUT * 1000000
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-5§4 Sulfur cube movement attributes: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-5-4.
