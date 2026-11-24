*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md), sections 1 and 2: the animate-tick scheduling facts, the fluid drip
*> placement and the shared helper algorithms of ParticleUtils (the position and speed rules live in particles-42-4-d.cob and
*> particles-42-5.cob: P4-SPAWN-BELOW-INT, P4-SPAWN-PARTICLE, P4-IN-BLOCK-EXTENT, P4-AXIS-PARTICLE, P5-FACE-POS). Draws are
*> passed in as values (a nextFloat or nextDouble in [0, 1), a nextInt(n) as the float r with floor(r * n)).
*>
*> Entry points for the integrator (inputs):
*>   P6-FACTS fact: scheduling constants; P6-DRIP-CHANCE draw: the 1 in 10 drip chance of a fluid cell;
*>   P6-DRIP-PLACE below-has-fluid top bottom sturdy impermeable under-top under-has-fluid: mode and y offset out;
*>   P6-DRIP-POS below-position minx maxx minz maxz rx rz y-offset: the drip position; P6-RANDOM-SPEED draws: the face speed;
*>   P6-DIRECTION-PICK draw / P6-DIRECTION-NAME index: Direction.getRandom and the Direction.values() order.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-FACTS.
*> Section 1.2: USING fact (1 iterations 667, 2 first radius 16, 3 second radius 32, 4 samples per tick 1334, 5 random sources 3,
*> 6 drip chance denominator 10), value out (0 for an unknown fact).
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
         WHEN 5
             MOVE 3 TO L-VALUE
         WHEN 6
             MOVE 10 TO L-VALUE
         WHEN OTHER
             MOVE 0 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DRIP-CHANCE.
*> Section 1.2 step 3: USING draw r (nextInt(10) as r), spawn out: when nextInt(10) == 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-SPAWN.
     MOVE 0 TO L-SPAWN
     IF L-R < 0.1
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM P6-DRIP-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DRIP-PLACE.
*> Section 1.5 trySpawnDripParticles: USING block below has a fluid (0/1), collision shape max y of the block below (0 when
*> empty), shape min y, the fluid cell's bottom face is sturdy (0/1), the block below is impermeable (0/1), collision shape max
*> y of the block under that, that block has a fluid (0/1), mode out (0 nothing, 1 the unit square at y offset 0.95, 2 the
*> shape extents at y offset bottom - 0.05, 3 the shape extents at y offset -0.05), y offset out (from the block below's Y).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-TOP                  FLOAT-LONG.
 01 L-BOTTOM               FLOAT-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-IMPERMEABLE          BINARY-LONG.
 01 L-UNDER-TOP            FLOAT-LONG.
 01 L-UNDER-FLUID          BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-YOFF                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-FLUID L-TOP L-BOTTOM L-STURDY L-IMPERMEABLE L-UNDER-TOP L-UNDER-FLUID L-MODE L-YOFF.
     MOVE 0 TO L-MODE
     MOVE 0 TO L-YOFF
     IF L-FLUID = 0
         IF L-TOP < 1
             IF L-STURDY NOT = 0
                 MOVE 1 TO L-MODE
                 COMPUTE L-YOFF = 1 - 0.05
             END-IF
         ELSE
             IF L-IMPERMEABLE = 0
                 IF L-BOTTOM > 0
                     MOVE 2 TO L-MODE
                     COMPUTE L-YOFF = L-BOTTOM - 0.05
                 ELSE
                     IF L-UNDER-TOP < 1 AND L-UNDER-FLUID = 0
                         MOVE 3 TO L-MODE
                         COMPUTE L-YOFF = 0 - 0.05
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-DRIP-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DRIP-POS.
*> Section 1.6 spawnFluidParticle: USING block position below (three integers), minimum x, maximum x, minimum z, maximum z (0 and
*> 1 for the unit square), nextDouble x draw, nextDouble z draw, y offset, position out: lerp(draw, X + min, X + max), Y + offset.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-MINX                 FLOAT-LONG.
 01 L-MAXX                 FLOAT-LONG.
 01 L-MINZ                 FLOAT-LONG.
 01 L-MAXZ                 FLOAT-LONG.
 01 L-RX                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 01 L-YOFF                 FLOAT-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-MINX L-MAXX L-MINZ L-MAXZ L-RX L-RZ L-YOFF L-OUT.
     COMPUTE L-O(1) = L-PP(1) + L-MINX + L-RX * (L-MAXX - L-MINX)
     COMPUTE L-O(2) = L-PP(2) + L-YOFF
     COMPUTE L-O(3) = L-PP(3) + L-MINZ + L-RZ * (L-MAXZ - L-MINZ)
     GOBACK.
 END PROGRAM P6-DRIP-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-RANDOM-SPEED.
*> Section 2.1 randomSpeedRanges: USING three nextDouble draws, speed out: Mth.nextDouble(-0.5, 0.5) = draw - 0.5 on each axis.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-S.
    05 L-SS                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-U L-S.
     COMPUTE L-SS(1) = L-UU(1) - 0.5
     COMPUTE L-SS(2) = L-UU(2) - 0.5
     COMPUTE L-SS(3) = L-UU(3) - 0.5
     GOBACK.
 END PROGRAM P6-RANDOM-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DIRECTION-PICK.
*> Section 2.2 Direction.getRandom: USING draw r (nextInt(6) as r), index out (0 DOWN to 5 EAST) = floor(r * 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-INDEX.
     COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-R * 6)
     GOBACK.
 END PROGRAM P6-DIRECTION-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DIRECTION-NAME.
*> Section 2.1 Direction.values() order: USING index (0 to 5), name out (PIC X(8): down, up, north, south, west, east; spaces out
*> of range).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(8).
 PROCEDURE DIVISION USING L-INDEX L-NAME.
     EVALUATE L-INDEX
         WHEN 0
             MOVE "down" TO L-NAME
         WHEN 1
             MOVE "up" TO L-NAME
         WHEN 2
             MOVE "north" TO L-NAME
         WHEN 3
             MOVE "south" TO L-NAME
         WHEN 4
             MOVE "west" TO L-NAME
         WHEN 5
             MOVE "east" TO L-NAME
         WHEN OTHER
             MOVE SPACES TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-DIRECTION-NAME.
