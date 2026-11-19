*> What a standard mob takes from its surroundings (docs/protocol/18-mob-framework.md sections 2.5, 3.2 fall damage, 3.3 cramming, 7.3; lane 002-lane-mobsfull-h15).
*>
*>   M182-TAG USING species key (PIC X(24)), tag (1 fall_damage_immune, 2 can_breathe_under_water), in tag out (BINARY-LONG)   the entity type tags of doc 21 section 3.6
*>   M182-FALL-DAMAGE USING distance (FLOAT-LONG), damage out (BINARY-LONG)       floor(distance + 1.0E-6 - 3), never below 0
*>   M182-FLUID USING dim, x, y, z, extent (FLOAT-LONG), kind (1 water, 2 lava), touches out (BINARY-LONG)   a column cell from y up to y + extent holds that fluid with its surface not below y
*>   M182-ENV-TICK USING tracker row of a standard mob       Entity.baseTick and LivingEntity.baseTick (2.5): fire, lava, below the world, in-wall damage, air supply and drowning, cramming
*>   M182-FALL USING tracker row, y before the move (FLOAT-LONG)       the fall distance of a move and the damage of the landing (3.2); a creeper's swell too (20 section 6.1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-TAG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-TAG                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TAG L-IN.
     MOVE 0 TO L-IN
     IF L-TAG = 1
         EVALUATE L-KEY
             WHEN "copper_golem" WHEN "iron_golem" WHEN "snow_golem" WHEN "shulker" WHEN "allay" WHEN "bat" WHEN "bee" WHEN "blaze" WHEN "cat"
             WHEN "chicken" WHEN "ghast" WHEN "happy_ghast" WHEN "phantom" WHEN "magma_cube" WHEN "ocelot" WHEN "parrot" WHEN "wither" WHEN "breeze"
                 MOVE 1 TO L-IN
         END-EVALUATE
     ELSE
*>       The undead tag (skeletons, zombies, wither, phantom) and the water creatures.
         EVALUATE L-KEY
             WHEN "skeleton" WHEN "stray" WHEN "wither_skeleton" WHEN "skeleton_horse" WHEN "bogged" WHEN "parched"
             WHEN "zombie_horse" WHEN "camel_husk" WHEN "zombie" WHEN "zombie_villager" WHEN "zombified_piglin" WHEN "zoglin" WHEN "drowned"
             WHEN "husk" WHEN "zombie_nautilus" WHEN "wither" WHEN "phantom"
             WHEN "axolotl" WHEN "frog" WHEN "guardian" WHEN "elder_guardian" WHEN "turtle" WHEN "glow_squid" WHEN "cod" WHEN "pufferfish"
             WHEN "salmon" WHEN "squid" WHEN "tropical_fish" WHEN "tadpole" WHEN "armor_stand" WHEN "copper_golem" WHEN "nautilus"
                 MOVE 1 TO L-IN
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM M182-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-FALL-DAMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-DAMAGE.
     COMPUTE L-DAMAGE = FUNCTION INTEGER(L-DISTANCE + 0.000001 - 3)
     IF L-DAMAGE < 0
         MOVE 0 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM M182-FALL-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-FLUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-A-FLUID             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EXTENT               FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-TOUCHES              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EXTENT L-KIND L-TOUCHES.
     MOVE 0 TO L-TOUCHES
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y)
     COMPUTE WS-HIGH = L-Y + L-EXTENT
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-HIGH)
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1 OR L-TOUCHES = 1
         CALL "FLUID-CELL" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-FLUID = L-KIND
             COMPUTE WS-YA = WS-Y + 1
             CALL "FLUID-CELL" USING L-DIM WS-X WS-YA WS-Z WS-STATE WS-A-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
             MOVE 0 TO WS-SAME
             IF WS-A-FLUID = L-KIND
                 MOVE 1 TO WS-SAME
             END-IF
             CALL "FLUID-CELL" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
             CALL "FL-HEIGHT" USING WS-AMOUNT WS-SAME WS-HEIGHT
             COMPUTE WS-TOP = WS-Y + WS-HEIGHT
             IF WS-TOP >= L-Y
                 MOVE 1 TO L-TOUCHES
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M182-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-TOUCHING.
*> USING tracker row of a standard mob, its height (FLOAT-LONG), count out (BINARY-LONG): the cramming count of M182-ENV-TICK (3.3 pushEntities): the living entities of its dimension
*> (a player, or a standard mob with health left) whose boxes overlap that of the mob (the horizontal reach is half the two widths, the vertical one the mob's height above and the other's
*> height below). The rows are walked up to the highest used row (EN-COUNT) and the cheap box test comes before the species lookup that the livingness needs, which is only asked of an
*> overlapping row; the absolute differences are taken by a sign test, where FUNCTION ABS is a libcob call: a village's environment tick spent 40 percent of itself in this loop.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 01 WS-OTHER-M             BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-TOUCHING             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HEIGHT L-TOUCHING.
     MOVE 0 TO L-TOUCHING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF WS-I NOT = L-ROW AND EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = EN-DIM(L-ROW)
             COMPUTE WS-HALF = (ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) + ET-WIDTH-MILLI(EN-TYPE(WS-I) + 1)) / 2000
             COMPUTE WS-DX = EN-X(WS-I) - EN-X(L-ROW)
             IF WS-DX < 0
                 COMPUTE WS-DX = 0 - WS-DX
             END-IF
             COMPUTE WS-DZ = EN-Z(WS-I) - EN-Z(L-ROW)
             IF WS-DZ < 0
                 COMPUTE WS-DZ = 0 - WS-DZ
             END-IF
             COMPUTE WS-DY = EN-Y(WS-I) - EN-Y(L-ROW)
             IF WS-DX < WS-HALF AND WS-DZ < WS-HALF AND WS-DY < L-HEIGHT AND WS-DY > - ET-HEIGHT-MILLI(EN-TYPE(WS-I) + 1) / 1000
                 MOVE 0 TO WS-LIVING
                 IF EN-PLAYER(WS-I) > 0
                     MOVE 1 TO WS-LIVING
                 ELSE
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-I) WS-OTHER-M
                     IF WS-OTHER-M > 0 AND EN-HEALTH(WS-I) > 0
                         MOVE 1 TO WS-LIVING
                     END-IF
                 END-IF
                 IF WS-LIVING = 1
                     ADD 1 TO L-TOUCHING
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M182-TOUCHING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-ENV-TICK.
*> USING tracker row of a standard mob, in the order of 2.5: the fire (a fire-immune type has it cleared; water puts it out; every tick where the count is a multiple
*> of 20 and the mob is not in lava it takes 1.0 on_fire damage, then the count falls by 1), lava (the fall distance halves; 4.0 lava damage and fifteen seconds of fire
*> unless fire immune), the head inside a solid block (1.0 in_wall), the air supply (the eye in water and the mob cannot breathe under water: 1 less a tick, at -20 it
*> is reset to 0 with Entity Event 67 and 2.0 drown damage; otherwise it refills by 4 a tick to 300; EN-AIR-LOST counts what is missing from 300) and cramming
*> (3.3: a 1 in 4 draw a tick; the mobs whose boxes overlap are counted against max_entity_cramming, GR-CRAMMING: 6.0). Fire Resistance (EN-FX-FIRE) ignores the
*> fire and lava damage. A mob that dies in a step ends the tick there. The eye height is that of the registry row (18 section 1.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY DIMENSIONS.
 COPY PROTO.
 COPY MOB181.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-WET                 BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG VALUE 2.
 01 WS-BREATHES            BINARY-LONG.
 01 WS-IN-WATER            BINARY-LONG.
 01 WS-KIND-WATER          BINARY-LONG VALUE 1.
 01 WS-KIND-LAVA           BINARY-LONG VALUE 2.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FLUID-AMOUNT        BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 67.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "max_entity_cramming".
 01 WS-LIMIT               BINARY-DOUBLE.
 01 WS-LIMIT-N             BINARY-LONG.
 01 WS-TOUCHING            BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-DAMAGE              FLOAT-LONG.
 01 WS-BFIRE               BINARY-LONG.
 01 WS-BSNOW               BINARY-LONG.
 01 WS-HALF-W              FLOAT-LONG.
 01 WS-DRAW-F              BINARY-LONG.
 01 WS-TICKS-F             BINARY-LONG.
 01 WS-SECONDS-F           BINARY-LONG.
 01 WS-DREW-F              BINARY-LONG.
 01 WS-NOT-PLAYER          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "MOB-SPECIES-KEY" USING WS-ROW WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-R1
     COMPUTE WS-HEIGHT = M1-H(WS-R1) / 1000000
     COMPUTE WS-EYE = EN-Y(WS-ROW) + M1-EYE(WS-R1) / 1000000
     COMPUTE WS-IMMUNE = FUNCTION MOD(M1-FLAGS(WS-R1), 2)
     CALL "M182-FLUID" USING EN-DIM(WS-ROW) EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-HEIGHT WS-KIND-WATER WS-WET
     CALL "M182-FLUID" USING EN-DIM(WS-ROW) EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-HEIGHT WS-KIND-LAVA WS-LAVA
     COMPUTE WS-HALF-W = ET-WIDTH-MILLI(EN-TYPE(WS-ROW) + 1) / 2000
     CALL "FIRE-SCAN-BOX" USING EN-DIM(WS-ROW) EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-HALF-W WS-HEIGHT WS-BFIRE WS-BSNOW
*>   2. Fire. A fire-immune type has it cleared and water (and powder snow) puts it out; the damage is on the tick the count is a multiple of 20, not in lava.
     IF EN-BURN(WS-ROW) > 0
         IF WS-IMMUNE = 1 OR WS-WET = 1 OR WS-BSNOW = 1
             MOVE 0 TO EN-BURN(WS-ROW)
         ELSE
             IF FUNCTION MOD(EN-BURN(WS-ROW), 20) = 0 AND WS-LAVA = 0 AND EN-FX-FIRE(WS-ROW) = 0
                 MOVE 1 TO WS-AMOUNT
                 MOVE CAUSE-ON-FIRE TO WS-CAUSE
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             END-IF
             SUBTRACT 1 FROM EN-BURN(WS-ROW)
         END-IF
     END-IF
*>   3. Lava: the fall distance halves; 4.0 damage and fifteen seconds of fire for a mob that is not fire immune.
     IF WS-LAVA = 1
         COMPUTE EN-FALL(WS-ROW) = EN-FALL(WS-ROW) * 0.5
         IF WS-IMMUNE = 0
             IF EN-FX-FIRE(WS-ROW) = 0
                 MOVE 4 TO WS-AMOUNT
                 MOVE CAUSE-LAVA TO WS-CAUSE
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             END-IF
             IF EN-BURN(WS-ROW) < 300
                 MOVE 300 TO EN-BURN(WS-ROW)
             END-IF
         END-IF
     END-IF
*>   A fire block in the box (29b-8 section 2.10 fireIgnite: the count, then eight seconds; in_fire damage 1.0, soul fire 2.0 unless fire immune; Fire Resistance
*>   still ignites but takes none).
     IF WS-BFIRE > 0 AND WS-IMMUNE = 0
         COMPUTE WS-DRAW-F = FUNCTION MOD(CW-TICKS + WS-ROW, 2)
         CALL "GC8-FIRE-IGNITE" USING WS-IMMUNE EN-BURN(WS-ROW) WS-NOT-PLAYER WS-DRAW-F WS-TICKS-F WS-SECONDS-F WS-DREW-F
         MOVE WS-TICKS-F TO EN-BURN(WS-ROW)
         COMPUTE WS-TICKS-F = WS-SECONDS-F * 20
         CALL "MOB-IGNITE" USING WS-ROW WS-TICKS-F
         IF EN-FX-FIRE(WS-ROW) = 0
             MOVE WS-BFIRE TO WS-AMOUNT
             MOVE CAUSE-IN-FIRE TO WS-CAUSE
             CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
         END-IF
     END-IF
     IF EN-HEALTH(WS-ROW) = 0
         GOBACK
     END-IF
*>   4. Below the world (y under the minimum less 64): 4.0 fell_out_of_world damage every tick (the hurt window lets it through every 20).
     IF EN-Y(WS-ROW) < DM-MIN-Y(EN-DIM(WS-ROW)) - 64
         MOVE 4 TO WS-AMOUNT
         MOVE CAUSE-VOID TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
         IF EN-HEALTH(WS-ROW) = 0
             GOBACK
         END-IF
     END-IF
*>   LivingEntity.baseTick 3: the head inside a solid block (its cell has a collision shape) takes 1.0.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(WS-EYE)
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "FLUID-CELL" USING EN-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-STATE WS-FLUID WS-KIND WS-FLUID-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-SOLID = 1
         MOVE 1 TO WS-AMOUNT
         MOVE CAUSE-IN-WALL TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
         IF EN-HEALTH(WS-ROW) = 0
             GOBACK
         END-IF
     END-IF
*>   4. The air supply.
     CALL "M182-FLUID" USING EN-DIM(WS-ROW) EN-X(WS-ROW) WS-EYE EN-Z(WS-ROW) WS-ZERO WS-KIND-WATER WS-IN-WATER
     CALL "M182-TAG" USING WS-KEY WS-TAG WS-BREATHES
     IF WS-IN-WATER = 1 AND WS-BREATHES = 0 AND EN-FX-WATER(WS-ROW) = 0
         ADD 1 TO EN-AIR-LOST(WS-ROW)
         IF EN-AIR-LOST(WS-ROW) >= 320
             MOVE 300 TO EN-AIR-LOST(WS-ROW)
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(WS-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING WS-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             MOVE 2 TO WS-AMOUNT
             MOVE CAUSE-DROWN TO WS-CAUSE
             CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             IF EN-HEALTH(WS-ROW) = 0
                 GOBACK
             END-IF
         END-IF
     ELSE
         COMPUTE EN-AIR-LOST(WS-ROW) = FUNCTION MAX(0, EN-AIR-LOST(WS-ROW) - 4)
     END-IF
*>   2.6 step 11 freezing and 3.3 applyEffectsFromBlocks (core/src/mob-18-3.cob).
     CALL "M183-TICK" USING WS-ROW
     IF EN-HEALTH(WS-ROW) = 0
         GOBACK
     END-IF
*>   3.3 pushEntities: the draw first (the count only matters on a draw of 0, so the scan runs on a quarter of the ticks).
     MOVE EN-ID(WS-ROW) TO WS-ARG(1)
     MOVE CW-TICKS TO WS-ARG(2)
     MOVE 41 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DRAW = FUNCTION MOD(WS-R, 4)
     IF WS-DRAW = 0
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-LIMIT
         MOVE WS-LIMIT TO WS-LIMIT-N
         IF WS-LIMIT-N > 0
             CALL "M182-TOUCHING" USING WS-ROW WS-HEIGHT WS-TOUCHING
             MOVE WS-TOUCHING TO WS-FREE
             CALL "GR-CRAMMING" USING WS-LIMIT-N WS-TOUCHING WS-FREE WS-DRAW WS-DAMAGE
             IF WS-DAMAGE > 0
                 MOVE 6 TO WS-AMOUNT
                 MOVE CAUSE-CRAMMING TO WS-CAUSE
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M182-ENV-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-FALL-ADJUST.
*> USING species key (PIC X(24)), damage (BINARY-LONG, in and out): the species' own change to the fall damage int: a goat takes 10 less (GOAT_FALL_DAMAGE_REDUCTION, 19 section 10) and a frog 5 less (FROG_FALL_DAMAGE_REDUCTION, 19 section 11.1), never below 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-DAMAGE.
     IF L-KEY = "goat"
         COMPUTE L-DAMAGE = FUNCTION MAX(0, L-DAMAGE - 10)
     END-IF
     IF L-KEY = "frog"
         COMPUTE L-DAMAGE = FUNCTION MAX(0, L-DAMAGE - 5)
     END-IF
     GOBACK.
 END PROGRAM M182-FALL-ADJUST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M182-FALL.
*> USING tracker row of a standard mob after its move, y before the move: the distance fallen so far (EN-FALL) grows by what the move went down; touching water
*> ends the fall; on the ground the landing does floor(distance + 1.0E-6 - 3) fall damage unless the type is fall_damage_immune, a creeper adds the distance to its
*> swell, and the distance is zero again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 COPY MOB181.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-KIND-WATER          BINARY-LONG VALUE 1.
 01 WS-TAG                 BINARY-LONG VALUE 1.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-FALL.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-Y.
     MOVE L-ROW TO WS-ROW
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-M
     CALL "MOB-SPECIES-KEY" USING WS-ROW WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-R1
     COMPUTE WS-HEIGHT = M1-H(WS-R1) / 1000000
     CALL "M182-FLUID" USING EN-DIM(WS-ROW) EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-HEIGHT WS-KIND-WATER WS-WET
     IF WS-WET = 1
         MOVE 0 TO EN-FALL(WS-ROW)
         GOBACK
     END-IF
     IF EN-Y(WS-ROW) < L-Y
         COMPUTE EN-FALL(WS-ROW) = EN-FALL(WS-ROW) + L-Y - EN-Y(WS-ROW)
     END-IF
     IF EN-ON-GROUND(WS-ROW) = 1 AND EN-FALL(WS-ROW) > 0
         IF SM-FUSE(WS-M) > 0
             CALL "STDMOB-CREEPER-FALL" USING WS-ROW EN-FALL(WS-ROW)
         END-IF
         CALL "M182-TAG" USING WS-KEY WS-TAG WS-IMMUNE
         IF WS-IMMUNE = 0
             CALL "M182-FALL-DAMAGE" USING EN-FALL(WS-ROW) WS-DAMAGE
             CALL "M182-FALL-ADJUST" USING WS-KEY WS-DAMAGE
             IF WS-DAMAGE > 0
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-NO-ATTACKER
             END-IF
         END-IF
         MOVE 0 TO EN-FALL(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM M182-FALL.
