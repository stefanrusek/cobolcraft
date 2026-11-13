*> Nether wart, cocoa, sweet berry bush and farmland (docs/protocol/29b part 2 sections 6 to 9) as programs of plain numbers (GB2- prefix, same conventions as growth-29b-2.cob: USING in out with
*> sixteen BINARY-LONG each, draws as inputs, float draws in millionths). Not wired into the play path. Sections 10 to 13 are in growth-29b-2c.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-WART.
*> USING in (age 0 to 3, the nextInt(10) draw, the block below is in supports_nether_wart), out (outline height in pixels 5 + 3a, can survive (no light test), randomly ticking, draws made, grows,
*> new age, valid bone meal target (always 0)): NetherWartBlock (6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-SUPPORT           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-HEIGHT            BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 L-TICKING           BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 L-GROWS             BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-BONE              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-HEIGHT = 5 + 3 * L-AGE
     MOVE L-SUPPORT TO L-SURVIVES
     MOVE 0 TO L-TICKING L-DRAWS L-GROWS L-BONE
     MOVE L-AGE TO L-NEW
     IF L-AGE < 3
         MOVE 1 TO L-TICKING L-DRAWS
         IF L-DRAW = 0
             MOVE 1 TO L-GROWS
             COMPUTE L-NEW = L-AGE + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-WART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-WART-DROP.
*> USING in (age, the nextInt(3) draw of U(2, 4), a tool is held (1/0), the Fortune level L, the nextInt(L + 1) draw), out (count, draws made, bound of the Fortune draw (0 when none)): the shipped drops
*> of 6 (data): age 3 sets the count to U(2, 4) then uniform_bonus_count (multiplier 1) adds the draw; any other age keeps 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-TOOL              BINARY-LONG.
    05 L-LEVEL             BINARY-LONG.
    05 L-BONUS             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 01 L-OUT.
    05 L-COUNT             BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 L-BOUND             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-COUNT
     MOVE 0 TO L-DRAWS L-BOUND
     IF L-AGE = 3
         COMPUTE L-COUNT = 2 + L-DRAW
         MOVE 1 TO L-DRAWS
         IF L-TOOL = 1
             ADD L-BONUS TO L-COUNT
             ADD 1 TO L-DRAWS
             COMPUTE L-BOUND = L-LEVEL + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-WART-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-COCOA.
*> USING in (facing 2 north 3 south 4 west 5 east, age 0 to 2, the block at pos.relative(facing) is in supports_cocoa, the nextInt(5) draw), out (can survive, randomly ticking, draws made, grows, new age,
*> bone meal valid, age after bone meal): CocoaBlock (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-FACING            BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-SUPPORT           BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-TICKING           BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 L-GROWS             BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-BONE              BINARY-LONG.
    05 L-BONE-NEW          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-SUPPORT TO L-SURVIVES
     MOVE 0 TO L-TICKING L-DRAWS L-GROWS L-BONE
     MOVE L-AGE TO L-NEW L-BONE-NEW
     IF L-AGE < 2
         MOVE 1 TO L-TICKING L-DRAWS L-BONE
         COMPUTE L-BONE-NEW = L-AGE + 1
         IF L-DRAW = 0
             MOVE 1 TO L-GROWS
             COMPUTE L-NEW = L-AGE + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-COCOA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-COCOA-UPDATE.
*> USING in (changed direction code, facing code, can survive), out (the state becomes air): updateShape (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-DIR               BINARY-LONG.
    05 L-FACING            BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-AIR               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-AIR
     IF L-DIR = L-FACING AND L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GB2-COCOA-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-COCOA-PLACE.
*> USING in (the horizontal directions of getNearestLookingDirections in order, four direction codes (0 for none); can survive with that facing, four flags), out (the facing chosen (-1 for no placement), its
*> position in the list (0 for none)): the placement state of 7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-DIR               BINARY-LONG OCCURS 4 TIMES.
    05 L-SURV              BINARY-LONG OCCURS 4 TIMES.
    05 FILLER              BINARY-LONG OCCURS 8 TIMES.
 01 L-OUT.
    05 L-FACING            BINARY-LONG.
    05 L-INDEX             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -1 TO L-FACING
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF L-INDEX = 0 AND L-DIR(WS-I) > 0 AND L-SURV(WS-I) = 1
             MOVE L-DIR(WS-I) TO L-FACING
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB2-COCOA-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-COCOA-SHAPE.
*> USING in (facing 2 north 3 south 4 west 5 east, age), out (x1, x2, z1, z2, y1, y2 in pixels): 24 part 4 6.23: north is column(4 + 2a, 7 - 2a, 12) shifted by 5 - a pixels north, rotated for the other facings.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-FACING            BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-X1                BINARY-LONG.
    05 L-X2                BINARY-LONG.
    05 L-Z1                BINARY-LONG.
    05 L-Z2                BINARY-LONG.
    05 L-Y1                BINARY-LONG.
    05 L-Y2                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-X1 = 6 - L-AGE
     COMPUTE WS-X2 = 10 + L-AGE
     MOVE 1 TO WS-Z1
     COMPUTE WS-Z2 = 5 + 2 * L-AGE
     COMPUTE L-Y1 = 7 - 2 * L-AGE
     MOVE 12 TO L-Y2
     EVALUATE L-FACING
         WHEN 3
             COMPUTE L-X1 = 16 - WS-X2
             COMPUTE L-X2 = 16 - WS-X1
             COMPUTE L-Z1 = 16 - WS-Z2
             COMPUTE L-Z2 = 16 - WS-Z1
         WHEN 5
             COMPUTE L-X1 = 16 - WS-Z2
             COMPUTE L-X2 = 16 - WS-Z1
             MOVE WS-X1 TO L-Z1
             MOVE WS-X2 TO L-Z2
         WHEN 4
             MOVE WS-Z1 TO L-X1
             MOVE WS-Z2 TO L-X2
             COMPUTE L-Z1 = 16 - WS-X2
             COMPUTE L-Z2 = 16 - WS-X1
         WHEN OTHER
             MOVE WS-X1 TO L-X1
             MOVE WS-X2 TO L-X2
             MOVE WS-Z1 TO L-Z1
             MOVE WS-Z2 TO L-Z2
     END-EVALUATE
     GOBACK.
 END PROGRAM GB2-COCOA-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BERRY-TICK.
*> USING in (age 0 to 3, the nextInt(5) draw, raw brightness at pos.above()), out (randomly ticking, draws made, grows, new age, game event block_change fired, bone meal valid, age after bone meal):
*> SweetBerryBushBlock random tick and bone meal (8): the draw is made first, the light test (9) only after a 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-TICKING           BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 L-GROWS             BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-EVENT             BINARY-LONG.
    05 L-BONE              BINARY-LONG.
    05 L-BONE-NEW          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-TICKING L-DRAWS L-GROWS L-EVENT L-BONE
     MOVE L-AGE TO L-NEW L-BONE-NEW
     IF L-AGE < 3
         MOVE 1 TO L-TICKING L-DRAWS L-BONE
         COMPUTE L-BONE-NEW = FUNCTION MIN(3, L-AGE + 1)
         IF L-DRAW = 0 AND L-LIGHT >= 9
             MOVE 1 TO L-GROWS L-EVENT
             COMPUTE L-NEW = L-AGE + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-BERRY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BERRY-INSIDE.
*> USING in (the entity is a LivingEntity, it is a fox or a bee, server level, age, the horizontal movement components x and z in billionths of a block), out (slowed, stuck multiplier x, y, z in
*> thousandths, hurt for 1.0): entityInside (8): slowed by (0.8, 0.75, 0.8); hurt on the server at age above 0 when |x| or |z| is at least the float 0.003 widened (0.003000000026077032).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-LIVING            BINARY-LONG.
    05 L-FOX-BEE           BINARY-LONG.
    05 L-SERVER            BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-VX                BINARY-LONG.
    05 L-VZ                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-SLOWED            BINARY-LONG.
    05 L-SX                BINARY-LONG.
    05 L-SY                BINARY-LONG.
    05 L-SZ                BINARY-LONG.
    05 L-HURT              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-SLOWED L-SX L-SY L-SZ L-HURT
     IF L-LIVING = 1 AND L-FOX-BEE = 0
         MOVE 1 TO L-SLOWED
         MOVE 800 TO L-SX L-SZ
         MOVE 750 TO L-SY
         IF L-SERVER = 1 AND L-AGE > 0 AND (FUNCTION ABS(L-VX) >= 3000001 OR FUNCTION ABS(L-VZ) >= 3000001)
             MOVE 1 TO L-HURT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-BERRY-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BERRY-USE.
*> USING in (age, the held stack is bone meal), out (useItemOn returns PASS so that bone meal proceeds): 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-BONE              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-PASS              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-PASS
     IF L-AGE NOT = 3 AND L-BONE = 1
         MOVE 1 TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM GB2-BERRY-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BERRY-HARVEST.
*> USING in (age, server level, the level random float in thousandths), out (success (client too), loot, sound and game event happen (server), new age, pick sound pitch in thousandths 800 + 0.4 r, game event
*> block_change fired): useWithoutItem (8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-SERVER            BINARY-LONG.
    05 L-R                 BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-SUCCESS           BINARY-LONG.
    05 L-EFFECTS           BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-PITCH             BINARY-LONG.
    05 L-EVENT             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-SUCCESS L-EFFECTS L-PITCH L-EVENT
     MOVE L-AGE TO L-NEW
     IF L-AGE > 1
         MOVE 1 TO L-SUCCESS
         IF L-SERVER = 1
             MOVE 1 TO L-EFFECTS L-EVENT L-NEW
             COMPUTE L-PITCH = 800 + 400 * L-R / 1000
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-BERRY-HARVEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BERRY-LOOT.
*> USING in (age, table 1 harvest or 2 breaking, the nextInt(2) draw of U(1, 2) or U(2, 3), the Fortune level L, the nextInt(L + 1) draw), out (berries): the shipped tables of 8 (data): harvest gives 1 at age 3 plus
*> U(1, 2); breaking gives U(2, 3) at age 3 or U(1, 2) at age 2, plus the Fortune bonus when L > 0 (breaking only), and nothing below age 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-TABLE             BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-LEVEL             BINARY-LONG.
    05 L-BONUS             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 01 L-OUT.
    05 L-COUNT             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-COUNT
     IF L-TABLE = 1
         COMPUTE L-COUNT = 1 + L-DRAW
         IF L-AGE = 3
             ADD 1 TO L-COUNT
         END-IF
     ELSE
         IF L-AGE = 3
             COMPUTE L-COUNT = 2 + L-DRAW
         END-IF
         IF L-AGE = 2
             COMPUTE L-COUNT = 1 + L-DRAW
         END-IF
         IF L-AGE > 1 AND L-LEVEL > 0
             ADD L-BONUS TO L-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-BERRY-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-FARM-SURVIVE.
*> USING in (the block above is solid, it is in maintains_farmland, the update direction is UP), out (can survive, a scheduled tick after 1 game tick, the scheduled tick turns it to the base block, the placement
*> state is farmland (1) or dirt (0)): 9.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SOLID             BINARY-LONG.
    05 L-MAINTAINS         BINARY-LONG.
    05 L-UP                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-SCHEDULE          BINARY-LONG.
    05 L-TURNS             BINARY-LONG.
    05 L-FARMLAND          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-SURVIVES L-SCHEDULE L-TURNS L-FARMLAND
     IF L-SOLID = 0 OR L-MAINTAINS = 1
         MOVE 1 TO L-SURVIVES L-FARMLAND
     ELSE
         MOVE 1 TO L-TURNS
         IF L-UP = 1
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-FARM-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-FARM-BOX.
*> USING in (unused), out (the water search box of 9.2: minimum x, y, z, maximum x, y, z relative to the block, and the number of cells).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 FILLER              BINARY-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-MIN-X             BINARY-LONG.
    05 L-MIN-Y             BINARY-LONG.
    05 L-MIN-Z             BINARY-LONG.
    05 L-MAX-X             BINARY-LONG.
    05 L-MAX-Y             BINARY-LONG.
    05 L-MAX-Z             BINARY-LONG.
    05 L-CELLS             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -4 TO L-MIN-X L-MIN-Z
     MOVE 0 TO L-MIN-Y
     MOVE 4 TO L-MAX-X L-MAX-Z
     MOVE 1 TO L-MAX-Y
     COMPUTE L-CELLS = (L-MAX-X - L-MIN-X + 1) * (L-MAX-Y - L-MIN-Y + 1) * (L-MAX-Z - L-MIN-Z + 1)
     GOBACK.
 END PROGRAM GB2-FARM-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-FARM-WET.
*> USING in (the number of cells of the box with a fluid in tag water, it is raining at pos.above()), out (wet): 9.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-WATER             BINARY-LONG.
    05 L-RAIN              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-WET               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-WET
     IF L-WATER > 0 OR L-RAIN = 1
         MOVE 1 TO L-WET
     END-IF
     GOBACK.
 END PROGRAM GB2-FARM-WET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-FARM-MOIST.
*> USING in (moisture 0 to 7, wet, the block above is in maintains_farmland), out (new moisture, action 0 nothing, 1 moisture written with flags 2, 2 turnToBaseBlock): the random tick of 9.2 (no draw).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-M                 BINARY-LONG.
    05 L-WET               BINARY-LONG.
    05 L-MAINTAINS         BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-NEW               BINARY-LONG.
    05 L-ACTION            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-M TO L-NEW
     MOVE 0 TO L-ACTION
     IF L-WET = 1
         IF L-M < 7
             MOVE 7 TO L-NEW
             MOVE 1 TO L-ACTION
         END-IF
     ELSE
         IF L-M > 0
             COMPUTE L-NEW = L-M - 1
             MOVE 1 TO L-ACTION
         ELSE
             IF L-MAINTAINS = 0
                 MOVE 2 TO L-ACTION
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-FARM-MOIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-FARM-TRAMPLE.
*> USING in (server level, the nextFloat draw in millionths, the fall distance d in thousandths, the entity is a LivingEntity, it is a Player, the position is under spawn protection, mob_griefing, the entity's
*> width and height in hundredths), out (trampled, the draw was made, the fall distance for the damage (d)): fallOn (9.3): the draw first, only on a server, then living, permission and the volume test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-VOLUME              BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SERVER            BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-D                 BINARY-LONG.
    05 L-LIVING            BINARY-LONG.
    05 L-PLAYER            BINARY-LONG.
    05 L-PROTECTED         BINARY-LONG.
    05 L-GRIEF             BINARY-LONG.
    05 L-W                 BINARY-LONG.
    05 L-H                 BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 7 TIMES.
 01 L-OUT.
    05 L-TRAMPLED          BINARY-LONG.
    05 L-DRAWN             BINARY-LONG.
    05 L-DAMAGE            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-TRAMPLED L-DRAWN
     MOVE L-D TO L-DAMAGE
     IF L-SERVER = 1
         MOVE 1 TO L-DRAWN
         MOVE 1 TO L-TRAMPLED
         COMPUTE WS-LIMIT = (L-D - 500) * 1000
         IF L-DRAW >= WS-LIMIT
             MOVE 0 TO L-TRAMPLED
         END-IF
         IF L-LIVING = 0
             MOVE 0 TO L-TRAMPLED
         END-IF
         IF L-PLAYER = 1 AND L-PROTECTED = 1
             MOVE 0 TO L-TRAMPLED
         END-IF
         IF L-PLAYER = 0 AND L-GRIEF = 0
             MOVE 0 TO L-TRAMPLED
         END-IF
         COMPUTE WS-VOLUME = L-W * L-W * L-H
         IF WS-VOLUME <= 512000
             MOVE 0 TO L-TRAMPLED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-FARM-TRAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-TURN-BASE.
*> USING in (unused), out (pushEntitiesUp runs first, the update flags of setBlockAndUpdate, game event block_change fired): turnToBaseBlock (9.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 FILLER              BINARY-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-PUSH              BINARY-LONG.
    05 L-FLAGS             BINARY-LONG.
    05 L-EVENT             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-PUSH L-EVENT
     MOVE 3 TO L-FLAGS
     GOBACK.
 END PROGRAM GB2-TURN-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PUSH-UP.
*> USING in (top of the old collision shape, top of the new one, bottom and top of an entity's box, all in hundredths of a pixel and measured from the block's floor, shapes being columns from 0), out (the delta is
*> empty, the delta's bottom, top, the entity overlaps it, lift of the entity in hundredths of a pixel): Block.pushEntitiesUp (9.5): the lift is the penetration depth into the delta.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-OLD               BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-BOTTOM            BINARY-LONG.
    05 L-TOP               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-EMPTY             BINARY-LONG.
    05 L-DELTA-BOTTOM      BINARY-LONG.
    05 L-DELTA-TOP         BINARY-LONG.
    05 L-OVERLAP           BINARY-LONG.
    05 L-LIFT              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-EMPTY
     MOVE 0 TO L-DELTA-BOTTOM L-DELTA-TOP L-OVERLAP L-LIFT
     IF L-NEW > L-OLD
         MOVE 0 TO L-EMPTY
         MOVE L-OLD TO L-DELTA-BOTTOM
         MOVE L-NEW TO L-DELTA-TOP
         IF L-BOTTOM < L-DELTA-TOP AND L-TOP > L-DELTA-BOTTOM
             MOVE 1 TO L-OVERLAP
             COMPUTE L-LIFT = L-DELTA-TOP - L-BOTTOM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-PUSH-UP.
