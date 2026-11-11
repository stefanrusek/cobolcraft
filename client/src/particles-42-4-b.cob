*> Particles part 4 (docs/protocol/42-particles-4-block-item-dust-ambient.md), sections 4 to 8: the block marker, falling
*> dust, the dust family, item break particles and the falling leaves. Draws are passed in as tables (see
*> particles-42-4.cob). The shared helpers P4-LIFE-BASE and P4-LIFE-F32 do the exact double and float32 steps
*> through the shim (cc_f64_*), so a truncation never lands one below.
*>
*> Entry points for the integrator (inputs):
*>   P4-MARKER-NEW PCL x y z lifetime-draw quad-draw; P4-MARKER-TARGET creative item-name block-item-flag, target out;
*>   P4-SAMPLE-POS px py pz ints(6) out(3); P4-FALLDUST-NEW PCL P4X x y z r g b draws(5);
*>   P4-FALLDUST-TICK PCL P4X PCL-COLLIDERS sprite-count; P4-FALLDUST-EMIT pos(3) nextInt16 free rx rz, flag, pos out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LIFE-BASE.
*> Helper: base = (int)(numerator / (d * 0.8 + 0.2)) in double arithmetic: USING numerator, draw d, base out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K1                  COMP-2 VALUE 0.8.
 01 WS-K2                  COMP-2 VALUE 0.2.
 01 WS-T                   COMP-2.
 01 WS-U                   COMP-2.
 01 WS-Q                   COMP-2.
 LINKAGE SECTION.
 01 L-NUM                  COMP-2.
 01 L-D                    COMP-2.
 01 L-BASE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NUM L-D L-BASE.
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-D WS-K1 WS-T
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-K2 WS-U
     CALL STATIC "cc_f64_div" USING BY REFERENCE L-NUM WS-U WS-Q
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-Q L-BASE
     GOBACK.
 END PROGRAM P4-LIFE-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LIFE-F32.
*> Helper: lifetime = (int) max((float) base * k, 1.0f) in float32: USING base, k (a float32 value), lifetime out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   COMP-2.
 01 WS-P                   COMP-2.
 01 WS-P32                 COMP-2.
 01 WS-ONE                 COMP-2 VALUE 1.0.
 01 WS-M                   COMP-2.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-K                    COMP-2.
 01 L-LIFE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-K L-LIFE.
     MOVE L-BASE TO WS-B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-B L-K WS-P
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-P32
     CALL STATIC "cc_f64_max_j" USING BY REFERENCE WS-P32 WS-ONE WS-M
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-M L-LIFE
     GOBACK.
 END PROGRAM P4-LIFE-F32.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-GROW-SIZE.
*> Sections 5 and 6.1 getQuadSize(partial): USING PCL, partial, size out = quadSize * clamp((age + partial) /
*> lifetime * 32, 0, 1) (grow-in over the first 1/32 of the life).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-SIZE.
     COMPUTE WS-F = (PC-AGE + L-PARTIAL) / PC-LIFETIME * 32
     IF WS-F < 0
         MOVE 0 TO WS-F
     END-IF
     IF WS-F > 1
         MOVE 1 TO WS-F
     END-IF
     COMPUTE L-SIZE = PC-QUAD-SIZE * WS-F
     GOBACK.
 END PROGRAM P4-GROW-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPAWN-BELOW.
*> Section 15.2 spawnParticleBelow: USING block position (x, y, z), nextDouble x draw, nextDouble z draw, position out:
*> (x + rx, y - 0.05, z + rz).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                FLOAT-LONG OCCURS 3 TIMES.
 01 L-RX                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-RX L-RZ L-POS.
     COMPUTE L-O(1) = L-PP(1) + L-RX
     COMPUTE L-O(2) = L-PP(2) - 0.05
     COMPUTE L-O(3) = L-PP(3) + L-RZ
     GOBACK.
 END PROGRAM P4-SPAWN-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-MARKER-NEW.
*> Section 4 BlockMarker: USING PCL, x, y, z, lifetime draw, quad size draw: position-only base, gravity 0, lifetime 80,
*> no physics; the drawn size is the constant of P4-MARKER-SIZE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-R1 L-R2.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-R1
     CALL "PCL-QUAD-NEW" USING PCL L-R2
     MOVE 0 TO PC-GRAVITY
     MOVE 80 TO PC-LIFETIME
     MOVE 0 TO PC-HAS-PHYSICS
     GOBACK.
 END PROGRAM P4-MARKER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-MARKER-SIZE.
*> Section 4 getQuadSize: USING size out (the constant 0.5, whatever the age).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-SIZE.
     MOVE 0.5 TO L-SIZE
     GOBACK.
 END PROGRAM P4-MARKER-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-MARKER-TARGET.
*> Section 4 step 1: USING creative (0/1), main-hand item name (PIC X(16), no namespace), block item (0/1), target
*> out (0 none, 1 barrier, 2 light).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CREATIVE             BINARY-LONG.
 01 L-ITEM                 PIC X(16).
 01 L-BLOCK                BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-CREATIVE L-ITEM L-BLOCK L-TARGET.
     MOVE 0 TO L-TARGET
     IF L-CREATIVE NOT = 0 AND L-BLOCK NOT = 0
         IF L-ITEM = "barrier"
             MOVE 1 TO L-TARGET
         END-IF
         IF L-ITEM = "light"
             MOVE 2 TO L-TARGET
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P4-MARKER-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SAMPLE-INFO.
*> Section 4 step 2: USING fact (1 iterations 667, 2 first radius 16, 3 second radius 32, 4 positions per tick 1334),
*> value out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACT                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FACT L-VALUE.
     EVALUATE L-FACT
         WHEN 1
             MOVE 667 TO L-VALUE
         WHEN 2
             MOVE 16 TO L-VALUE
         WHEN 3
             MOVE 32 TO L-VALUE
         WHEN 4
             MOVE 1334 TO L-VALUE
         WHEN OTHER
             MOVE 0 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-SAMPLE-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SAMPLE-POS.
*> Section 4 step 3 doAnimateTick: USING px, py, pz (integers), six nextInt(r) draws (+x, -x, +y, -y, +z, -z), block
*> position out: (px + d1 - d2, py + d3 - d4, pz + d5 - d6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-INTS.
    05 L-N                 BINARY-LONG OCCURS 6 TIMES.
 01 L-OUT.
    05 L-O                 BINARY-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-PX L-PY L-PZ L-INTS L-OUT.
     COMPUTE L-O(1) = L-PX + L-N(1) - L-N(2)
     COMPUTE L-O(2) = L-PY + L-N(3) - L-N(4)
     COMPUTE L-O(3) = L-PZ + L-N(5) - L-N(6)
     GOBACK.
 END PROGRAM P4-SAMPLE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-MARKER-CENTER.
*> Section 4 step 6: USING block position (integers), centre x, y, z out (each plus 0.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-P L-X L-Y L-Z.
     COMPUTE L-X = L-PP(1) + 0.5
     COMPUTE L-Y = L-PP(2) + 0.5
     COMPUTE L-Z = L-PP(3) + 0.5
     GOBACK.
 END PROGRAM P4-MARKER-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-BRANCH.
*> Section 5 provider: USING is FallingBlock (0/1), has tint source of index 0 (0/1), branch out: 1 getDustColor,
*> 2 the terrain tint colour, 3 the map colour.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALLING              BINARY-LONG.
 01 L-TINT                 BINARY-LONG.
 01 L-BRANCH               BINARY-LONG.
 PROCEDURE DIVISION USING L-FALLING L-TINT L-BRANCH.
     EVALUATE TRUE
         WHEN L-FALLING NOT = 0
             MOVE 1 TO L-BRANCH
         WHEN L-TINT NOT = 0
             MOVE 2 TO L-BRANCH
         WHEN OTHER
             MOVE 3 TO L-BRANCH
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-FALLDUST-BRANCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-BLOCK-COLOR.
*> Section 5 table: USING block name (PIC X(32), no namespace), colour out (BINARY-DOUBLE), kind out: 1 a fixed
*> colour (sand, red_sand, gravel, dragon_egg), 2 the map colour (concrete powder, the anvils; colour out 0),
*> 0 not a FallingBlock (a brushable block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAIL                PIC X(16).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-COLOR                BINARY-DOUBLE.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-COLOR L-KIND.
     MOVE 0 TO L-COLOR
     MOVE 1 TO L-KIND
     EVALUATE TRUE
         WHEN L-NAME = "sand"
             MOVE 14406560 TO L-COLOR
         WHEN L-NAME = "red_sand"
             MOVE 11098145 TO L-COLOR
         WHEN L-NAME = "gravel"
             MOVE -8356741 TO L-COLOR
         WHEN L-NAME = "dragon_egg"
             MOVE -16777216 TO L-COLOR
         WHEN OTHER
             MOVE 0 TO L-KIND
             COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-NAME))
             IF WS-LEN >= 15
                 MOVE L-NAME(WS-LEN - 14:15) TO WS-TAIL
                 IF WS-TAIL(1:15) = "concrete_powder"
                     MOVE 2 TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 5
                 MOVE L-NAME(WS-LEN - 4:5) TO WS-TAIL
                 IF WS-TAIL(1:5) = "anvil"
                     MOVE 2 TO L-KIND
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-FALLDUST-BLOCK-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-RGB.
*> Section 5 provider: USING colour int c, r, g, b out: ((c >> 16) & 255) / 255 and so on; the alpha byte is dropped.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-DOUBLE.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-C L-R L-G L-B.
     CALL "PART-RGB24" USING L-C L-R L-G L-B
     GOBACK.
 END PROGRAM P4-FALLDUST-RGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-NEW.
*> Section 5 constructor: USING PCL, P4X, x, y, z, r, g, b (the colour channels), draws (1 lifetime of the base, 2 quad
*> size, 3 f, 4 rotSpeed, 5 roll). Colours as given; quadSize * 0.67499995; base = (int)(32 / (f * 0.8 + 0.2));
*> lifetime = (int) max(base * 0.9f, 1); rotSpeed = (draw - 0.5) * 0.1; roll = draw * 6.2831855; sprite 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-32                  COMP-2 VALUE 32.
 01 WS-K09                 COMP-2 VALUE 0.8999999761581421.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-R L-G L-B L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE L-R TO PC-RCOL
     MOVE L-G TO PC-GCOL
     MOVE L-B TO PC-BCOL
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.67499995
     CALL "P4-LIFE-BASE" USING WS-32 L-DRAW(3) WS-BASE
     CALL "P4-LIFE-F32" USING WS-BASE WS-K09 PC-LIFETIME
     MOVE 0 TO PC-SPRITE
     COMPUTE X4-ROT-SPEED = (L-DRAW(4) - 0.5) * 0.1
     COMPUTE PC-ROLL = L-DRAW(5) * 6.2831855
     MOVE PC-ROLL TO PC-OROLL
     GOBACK.
 END PROGRAM P4-FALLDUST-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-TICK.
*> Section 5 tick: USING PCL, P4X, PCL-COLLIDERS, sprite count. 1 old position = position, an old age >= lifetime
*> removes (age incremented); 2 sprite from age; 3 oRoll = roll, roll += 3.1415927 * rotSpeed * 2, reset to 0 on the
*> ground; 4 move; 5 yd -= 0.003000000026077032, yd = max(yd, -0.14000000059604645).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL P4X PCL-COLLIDERS L-N.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     MOVE PC-ROLL TO PC-OROLL
     COMPUTE PC-ROLL = PC-ROLL + 3.1415927 * X4-ROT-SPEED * 2
     IF PC-ON-GROUND NOT = 0
         MOVE 0 TO PC-ROLL PC-OROLL
     END-IF
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-YD = PC-YD - 0.003000000026077032
     IF PC-YD < -0.14000000059604645
         MOVE -0.14000000059604645 TO PC-YD
     END-IF
     GOBACK.
 END PROGRAM P4-FALLDUST-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FALLDUST-EMIT.
*> Section 5 emission (FallingBlock and BrushableBlock animateTick): USING block position (x, y, z), nextInt(16) value,
*> block below is free (0/1), nextDouble x, nextDouble z, emit out (0/1), position out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                FLOAT-LONG OCCURS 3 TIMES.
 01 L-INT                  BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-RX                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-INT L-FREE L-RX L-RZ L-POS L-EMIT.
     MOVE 0 TO L-EMIT
     IF L-INT = 0 AND L-FREE NOT = 0
         MOVE 1 TO L-EMIT
         CALL "P4-SPAWN-BELOW" USING L-P L-RX L-RZ L-POS
     END-IF
     GOBACK.
 END PROGRAM P4-FALLDUST-EMIT.
