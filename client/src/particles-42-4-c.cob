*> Particles part 4 (docs/protocol/42-particles-4-block-item-dust-ambient.md), sections 6 to 9: the dust family, the item break
*> particles, the falling leaves and the ash particles. Draws are passed in as tables (see particles-42-4.cob).
*>
*> Entry points for the integrator (inputs):
*>   P4-DUST-NEW PCL x y z vx vy vz scale draws(11) lifetime-double argb;
*>   P4-DUST-TRANSITION-NEW (same, then from-argb to-argb) and P4-DUST-TRANSITION-COLOR PCL P4X partial (each draw);
*>   P4-ITEM-CORE-NEW PCL P4X x y z draws(9); P4-ITEM-VEL-NEW (adds vx vy vz); P4-ITEM-PICK layer-count draw;
*>   P4-LEAF-NEW PCL PCLX x y z type-id draws(6), then P4-LEAF-TINT PCL argb for tinted_leaves;
*>   P4-ASH-NEW PCL x y z draws(9); P4-WHITE-ASH-NEW PCL x y z draws(9) six-draws.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-BASE-NEW.
*> Section 6.1 DustParticleBase: USING PCL, x, y, z, vx, vy, vz, scale, draws (1-6 burst, 7 quad size), lifetime double d.
*> friction 0.96, speedUp, velocity * 0.10000000149011612, quadSize * 0.75 * scale, base = (int)(8 / (d * 0.8 + 0.2)),
*> lifetime = (int) max((float) base * scale, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-8                   COMP-2 VALUE 8.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-D                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-D.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-XD = PC-XD * 0.10000000149011612
     COMPUTE PC-YD = PC-YD * 0.10000000149011612
     COMPUTE PC-ZD = PC-ZD * 0.10000000149011612
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75 * L-SCALE
     CALL "P4-LIFE-BASE" USING WS-8 L-D WS-BASE
     CALL "P4-LIFE-F32" USING WS-BASE L-SCALE PC-LIFETIME
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P4-DUST-BASE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-RANDOMIZE.
*> Section 6.1 randomizeColor(a, b): USING draw, a, b, result out = (draw * 0.2 + 0.8) * a * b.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DRAW L-A L-B L-OUT.
     COMPUTE L-OUT = (L-DRAW * 0.2 + 0.8) * L-A * L-B
     GOBACK.
 END PROGRAM P4-DUST-RANDOMIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-NEW.
*> Section 6.2 DustParticle: USING PCL, x, y, z, vx, vy, vz, scale, draws (1-7 base, 8 f, 9-11 the channels),
*> lifetime double, option colour (RGB24 in an int). f = draw * 0.4 + 0.6; each channel randomizeColor(colour, f).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-D                    FLOAT-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-D L-ARGB.
     CALL "P4-DUST-BASE-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-D
     CALL "PART-RGB24" USING L-ARGB WS-CX WS-CY WS-CZ
     COMPUTE WS-F = L-DRAW(8) * 0.4 + 0.6
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(9) WS-CX WS-F PC-RCOL
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(10) WS-CY WS-F PC-GCOL
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(11) WS-CZ WS-F PC-BCOL
     GOBACK.
 END PROGRAM P4-DUST-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-TRANSITION-NEW.
*> Section 6.3 DustColorTransitionParticle: USING PCL, P4X, x, y, z, vx, vy, vz, scale, draws (1-7 base, 8 f, 9-11 the
*> from channels, 12-14 the to channels), lifetime double, from colour, to colour. The colours are stored in
*> X4-FROM and X4-TO; PC-RCOL and the others are set by P4-DUST-TRANSITION-COLOR at each extraction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-D                    FLOAT-LONG.
 01 L-FROM                 BINARY-DOUBLE.
 01 L-TO                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-D L-FROM L-TO.
     CALL "P4-DUST-BASE-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-D
     COMPUTE WS-F = L-DRAW(8) * 0.4 + 0.6
     CALL "PART-RGB24" USING L-FROM WS-CX WS-CY WS-CZ
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(9) WS-CX WS-F X4-FROM(1)
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(10) WS-CY WS-F X4-FROM(2)
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(11) WS-CZ WS-F X4-FROM(3)
     CALL "PART-RGB24" USING L-TO WS-CX WS-CY WS-CZ
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(12) WS-CX WS-F X4-TO(1)
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(13) WS-CY WS-F X4-TO(2)
     CALL "P4-DUST-RANDOMIZE" USING L-DRAW(14) WS-CZ WS-F X4-TO(3)
     GOBACK.
 END PROGRAM P4-DUST-TRANSITION-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-TRANSITION-COLOR.
*> Section 6.3 extraction: USING PCL, P4X, partial: t = (age + partial) / (lifetime + 1); colour = from + (to - from) * t.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-PARTIAL              FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P4X L-PARTIAL.
     COMPUTE WS-T = (PC-AGE + L-PARTIAL) / (PC-LIFETIME + 1)
     COMPUTE PC-RCOL = X4-FROM(1) + (X4-TO(1) - X4-FROM(1)) * WS-T
     COMPUTE PC-GCOL = X4-FROM(2) + (X4-TO(2) - X4-FROM(2)) * WS-T
     COMPUTE PC-BCOL = X4-FROM(3) + (X4-TO(3) - X4-FROM(3)) * WS-T
     GOBACK.
 END PROGRAM P4-DUST-TRANSITION-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-DUST-OPTION.
*> Section 6.3 option constants: USING kind (0 REDSTONE, 1 SCULK_TO_REDSTONE), from colour, to colour (RGB24 ints; REDSTONE
*> repeats its colour), scale out (1.0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FROM                 BINARY-DOUBLE.
 01 L-TO                   BINARY-DOUBLE.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-FROM L-TO L-SCALE.
     MOVE 16711680 TO L-FROM L-TO
     IF L-KIND = 1
         MOVE 3790560 TO L-FROM
     END-IF
     MOVE 1.0 TO L-SCALE
     GOBACK.
 END PROGRAM P4-DUST-OPTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-ITEM-CORE-NEW.
*> Section 7.1 core constructor: USING PCL, P4X, x, y, z, draws (1-6 the burst with a zero bias, 7 the quad size, 8 uo,
*> 9 vo). gravity 1, quadSize halved, uo = r * 3, vo = r * 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-DRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z WS-ZERO WS-ZERO-Y WS-ZERO-Z L-DRAWS
     MOVE 1.0 TO PC-GRAVITY
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE / 2
     COMPUTE X4-UO = L-DRAW(8) * 3.0
     COMPUTE X4-VO = L-DRAW(9) * 3.0
     GOBACK.
 END PROGRAM P4-ITEM-CORE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-ITEM-VEL-NEW.
*> Section 7.1 velocity constructor: USING PCL, P4X, x, y, z, vx, vy, vz, draws: the core constructor, then
*> velocity = velocity * 0.10000000149011612 + the supplied velocity.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "P4-ITEM-CORE-NEW" USING PCL P4X L-X L-Y L-Z L-DRAWS
     COMPUTE PC-XD = PC-XD * 0.10000000149011612 + L-VX
     COMPUTE PC-YD = PC-YD * 0.10000000149011612 + L-VY
     COMPUTE PC-ZD = PC-ZD * 0.10000000149011612 + L-VZ
     GOBACK.
 END PROGRAM P4-ITEM-VEL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-ITEM-PICK.
*> Section 7.2 pickParticleMaterial: USING active layer count, draw r, index out (-1: the missing sprite), drawn out
*> (1 when the one nextInt(count) draw was consumed, 0 with no active layer).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-R L-INDEX L-DRAWN.
     IF L-COUNT <= 0
         MOVE -1 TO L-INDEX
         MOVE 0 TO L-DRAWN
     ELSE
         COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-R * L-COUNT)
         MOVE 1 TO L-DRAWN
     END-IF
     GOBACK.
 END PROGRAM P4-ITEM-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-ITEM-TEMPLATE.
*> Sections 7.2 to 7.4: USING registry id (57 item, 62 item_slime, 63 item_cobweb, 64 item_snowball, 127 sulfur_cube_goo),
*> item name out (spaces: from the option or the sprite set), ignores velocity out (1 for the core-constructor
*> types, 0 for item).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-IGNORES              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-IGNORES.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-IGNORES
     EVALUATE L-ID
         WHEN 62
             MOVE "slime_ball" TO L-NAME
             MOVE 1 TO L-IGNORES
         WHEN 63
             MOVE "cobweb" TO L-NAME
             MOVE 1 TO L-IGNORES
         WHEN 64
             MOVE "snowball" TO L-NAME
             MOVE 1 TO L-IGNORES
         WHEN 127
             MOVE 1 TO L-IGNORES
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-ITEM-TEMPLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-ARGS.
*> Section 8.2: USING type id (41 cherry, 42 pale oak, 43-45 poplars, 46 tinted), args out (gravityScale, windBig, swirl,
*> flowAway, sizeScale, fallSpeed: the layout of PFALL-NEW), sprite count out (12, 12, 4, 12).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ARGS.
    05 L-GRAVITY-SCALE     FLOAT-LONG.
    05 L-WIND-BIG          FLOAT-LONG.
    05 L-SWIRL             BINARY-LONG.
    05 L-FLOW-AWAY         BINARY-LONG.
    05 L-SIZE-SCALE        FLOAT-LONG.
    05 L-FALL-SPEED        FLOAT-LONG.
 01 L-SPRITES              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ARGS L-SPRITES.
     IF L-ID = 41
         MOVE 0.25 TO L-GRAVITY-SCALE
         MOVE 2.0 TO L-WIND-BIG
         MOVE 0 TO L-SWIRL
         MOVE 1 TO L-FLOW-AWAY
         MOVE 1.0 TO L-SIZE-SCALE
         MOVE 0.0 TO L-FALL-SPEED
     ELSE
         MOVE 0.07 TO L-GRAVITY-SCALE
         MOVE 10.0 TO L-WIND-BIG
         MOVE 1 TO L-SWIRL
         MOVE 0 TO L-FLOW-AWAY
         MOVE 2.0 TO L-SIZE-SCALE
         MOVE 0.021 TO L-FALL-SPEED
     END-IF
     IF L-ID >= 43 AND L-ID <= 45
         MOVE 4 TO L-SPRITES
     ELSE
         MOVE 12 TO L-SPRITES
     END-IF
     GOBACK.
 END PROGRAM P4-LEAF-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-SPRITE.
*> Section 8.2: USING sprite count n, draw r, index out = floor(r * n): sprites.get(random) is one nextInt(n).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-R L-INDEX.
     COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-R * L-N)
     GOBACK.
 END PROGRAM P4-LEAF-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-NEW.
*> Section 8.2: USING PCL, PCLX, x, y, z, type id (41 to 46), draws (the six of PFALL-NEW; the velocity arguments of the
*> call are ignored). The FallingParticle constructor with the numbers of P4-LEAF-ARGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-GS               FLOAT-LONG.
    05 WS-WB               FLOAT-LONG.
    05 WS-SW               BINARY-LONG.
    05 WS-FA               BINARY-LONG.
    05 WS-SZ               FLOAT-LONG.
    05 WS-FS               FLOAT-LONG.
 01 WS-SPRITES             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-ID L-DRAWS.
     CALL "P4-LEAF-ARGS" USING L-ID WS-ARGS WS-SPRITES
     CALL "PFALL-NEW" USING PCL PCLX L-X L-Y L-Z WS-ARGS L-DRAWS
     GOBACK.
 END PROGRAM P4-LEAF-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-TINT.
*> Section 8.2 tinted_leaves: USING PCL, colour int: setColor(red, green, blue), each byte / 255 (alpha ignored).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING PCL L-ARGB.
     CALL "PART-RGB24" USING L-ARGB WS-R WS-G WS-B
     CALL "PCL-SET-COLOR" USING PCL WS-R WS-G WS-B
     GOBACK.
 END PROGRAM P4-LEAF-TINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-CHANCE.
*> Section 8.4: USING leaf block name (PIC X(32), no namespace), chance out, particle id out (41 to 46, 0 when the block
*> emits nothing), colour out (0 = the client leaf tint, else the fixed ARGB int), found out (0/1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-CHANCE               FLOAT-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-CHANCE L-ID L-COLOR L-FOUND.
     MOVE 0 TO L-CHANCE L-ID L-COLOR
     MOVE 1 TO L-FOUND
     EVALUATE L-NAME
         WHEN "oak_leaves"
         WHEN "birch_leaves"
         WHEN "jungle_leaves"
         WHEN "acacia_leaves"
         WHEN "dark_oak_leaves"
         WHEN "mangrove_leaves"
             MOVE 0.01 TO L-CHANCE
             MOVE 46 TO L-ID
         WHEN "cherry_leaves"
             MOVE 0.1 TO L-CHANCE
             MOVE 41 TO L-ID
         WHEN "pale_oak_leaves"
             MOVE 0.02 TO L-CHANCE
             MOVE 42 TO L-ID
         WHEN "red_poplar_leaves"
             MOVE 0.01 TO L-CHANCE
             MOVE 43 TO L-ID
         WHEN "orange_poplar_leaves"
             MOVE 0.01 TO L-CHANCE
             MOVE 44 TO L-ID
         WHEN "yellow_poplar_leaves"
             MOVE 0.01 TO L-CHANCE
             MOVE 45 TO L-ID
         WHEN "azalea_leaves"
         WHEN "flowering_azalea_leaves"
             MOVE 0.01 TO L-CHANCE
             MOVE 46 TO L-ID
             MOVE -9399763 TO L-COLOR
         WHEN OTHER
             MOVE 0 TO L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-LEAF-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-EMIT.
*> Section 8.4: USING chance, nextFloat draw, up face of the block below is full (0/1), emit out: the draw is always
*> taken; it continues only when draw < chance, and stops when the face below is full.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANCE               FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-DRAW L-FULL L-EMIT.
     MOVE 0 TO L-EMIT
     IF L-DRAW < L-CHANCE AND L-FULL = 0
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM P4-LEAF-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEAF-TINT-COLOR.
*> Section 8.3 getClientLeafTintColor: USING has tint source of index 0 (0/1), in-world colour, colour out (-1, white,
*> without a tint source).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-IN                   BINARY-DOUBLE.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-HAS L-IN L-OUT.
     IF L-HAS NOT = 0
         MOVE L-IN TO L-OUT
     ELSE
         MOVE -1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM P4-LEAF-TINT-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-ASH-NEW.
*> Section 9 ash: USING PCL, x, y, z, draws (the nine of PASH-NEW): multipliers 0.1, -0.1, 0.1, add-ons 0, scale 1,
*> colour multiplier 0.5, lifetime base 20, gravity 0.1, no physics.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-VXM              FLOAT-LONG VALUE 0.1.
    05 WS-VYM              FLOAT-LONG VALUE -0.1.
    05 WS-VZM              FLOAT-LONG VALUE 0.1.
    05 WS-AX               FLOAT-LONG VALUE 0.
    05 WS-AY               FLOAT-LONG VALUE 0.
    05 WS-AZ               FLOAT-LONG VALUE 0.
    05 WS-SCALE            FLOAT-LONG VALUE 1.0.
    05 WS-COLOUR           FLOAT-LONG VALUE 0.5.
    05 WS-LIFE             FLOAT-LONG VALUE 20.
    05 WS-GRAVITY          FLOAT-LONG VALUE 0.1.
    05 WS-PHYSICS          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     GOBACK.
 END PROGRAM P4-ASH-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-WHITE-ASH-PROVIDER.
*> Section 9 WhiteAshParticle$Provider: USING six draws (r1 to r6), ax, ay, az out: ax = (r1 * -1.9) * r2 * 0.1,
*> ay = ((r3 * -0.5) * r4 * 0.1) * 5.0, az = (r5 * -1.9) * r6 * 0.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R6.
    05 L-R                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-AX                   FLOAT-LONG.
 01 L-AY                   FLOAT-LONG.
 01 L-AZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-R6 L-AX L-AY L-AZ.
     COMPUTE L-AX = (L-R(1) * -1.9) * L-R(2) * 0.1
     COMPUTE L-AY = ((L-R(3) * -0.5) * L-R(4) * 0.1) * 5.0
     COMPUTE L-AZ = (L-R(5) * -1.9) * L-R(6) * 0.1
     GOBACK.
 END PROGRAM P4-WHITE-ASH-PROVIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-WHITE-ASH-NEW.
*> Section 9 white_ash: USING PCL, x, y, z, draws (PASH-NEW), the six provider draws: add-ons from the provider, colour
*> multiplier 0, gravity 0.0125, then the colour is RGB24 12235202 (186, 177, 194 over 255).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-VXM              FLOAT-LONG VALUE 0.1.
    05 WS-VYM              FLOAT-LONG VALUE -0.1.
    05 WS-VZM              FLOAT-LONG VALUE 0.1.
    05 WS-AX               FLOAT-LONG.
    05 WS-AY               FLOAT-LONG.
    05 WS-AZ               FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG VALUE 1.0.
    05 WS-COLOUR           FLOAT-LONG VALUE 0.0.
    05 WS-LIFE             FLOAT-LONG VALUE 20.
    05 WS-GRAVITY          FLOAT-LONG VALUE 0.0125.
    05 WS-PHYSICS          BINARY-LONG VALUE 0.
 01 WS-RGB                 BINARY-DOUBLE VALUE 12235202.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R6.
    05 L-R                 FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS L-R6.
     CALL "P4-WHITE-ASH-PROVIDER" USING L-R6 WS-AX WS-AY WS-AZ
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     CALL "PART-RGB24" USING WS-RGB WS-R WS-G WS-B
     CALL "PCL-SET-COLOR" USING PCL WS-R WS-G WS-B
     GOBACK.
 END PROGRAM P4-WHITE-ASH-NEW.
