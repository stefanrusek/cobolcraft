*> Implementation test (002-lane-mobsfull-h15; docs/protocol/18 sections 2.5, 2.8 and 3.2 fall damage): what a standard land mob takes from its surroundings every tick
*> (M182-ENV-TICK): the on-fire tick (1.0 every 20 ticks, never in lava, fire-immune types and water put it out), lava (4.0 and 15 seconds of fire, fall distance
*> halved), drowning (air supply 300, 2.0 at -20, Entity Event 67), in-wall damage (1.0 with the head in a solid block), cramming (6.0), fall damage on landing
*> (floor(distance + 1.0E-6 - 3), the fall_damage_immune types and water excepted) and the player-responsibility memory of 100 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY RULES.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-CHICKEN-TYPE        BINARY-LONG.
 01 WS-PIGLIN-TYPE         BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-DTYPE               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "max_entity_cramming".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-HIT-DAMAGE          BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CHICKEN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombified_piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIGLIN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME

*>   Tags of the types (doc 21 section 3.6): fall_damage_immune (1), can_breathe_under_water (2).
     MOVE "zombie" TO WS-SPECIES
     MOVE 2 TO WS-TAG
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a zombie (undead) breathes under water" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "cow" TO WS-SPECIES
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a cow does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "cod" TO WS-SPECIES
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a cod breathes under water" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "chicken" TO WS-SPECIES
     MOVE 1 TO WS-TAG
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§3.2 travel: a chicken takes no fall damage (fall_damage_immune)" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "iron_golem" TO WS-SPECIES
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§3.2 travel: an iron golem takes no fall damage" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "cow" TO WS-SPECIES
     CALL "M182-TAG" USING WS-SPECIES WS-TAG WS-OBS
     MOVE "acceptance US15 18§3.2 travel: a cow takes fall damage" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The fall formula floor(distance + 1.0E-6 - 3): 3 blocks 0, 4 blocks 1, 10 blocks 7, 23 blocks 20 (17 section 4.12).
     MOVE 3.0 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: a fall of 3 blocks does no damage" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
     MOVE 4.0 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: a fall of 4 blocks does 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
     MOVE 10.0 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: a fall of 10 blocks does 7" TO WS-CASE
     MOVE 7 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
     MOVE 23.0 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: a fall of 23 blocks does 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
     MOVE 3.9999995 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: the 1.0E-6 margin counts 3.9999995 as 4" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE

*>   The causes of environmental damage have damage types (generic where the open set has none).
     PERFORM VARYING WS-CAUSE FROM CAUSE-ON-FIRE BY 1 UNTIL WS-CAUSE > CAUSE-VOID
         CALL "DAMAGE-TYPE-ID" USING WS-CAUSE WS-DTYPE
         MOVE "acceptance US15 18§7.3 Damage: the fire, lava, in-wall and cramming causes have a damage type" TO WS-CASE
         MOVE 1 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF WS-DTYPE >= 0
             MOVE 1 TO WS-OBS
         END-IF
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     END-PERFORM

*>   Fire: 1 damage on the ticks where the count is a multiple of 20, then it counts down; at 0 the fire is out.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-COW-TYPE WS-M
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 40 TO EN-BURN(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a burning mob takes 1 on the tick the count is 40" TO WS-CASE
     MOVE 19 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§2.5 Entity.baseTick: and the count falls by one" TO WS-CASE
     MOVE 39 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
     PERFORM TICK-ENV 19 TIMES
     MOVE "acceptance US15 18§2.5 Entity.baseTick: 19 more ticks to the count 20 do no damage" TO WS-CASE
     MOVE 19 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE 20 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: at the count 20 it takes the second point" TO WS-CASE
     MOVE 18 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     PERFORM TICK-ENV 19 TIMES
     MOVE "acceptance US15 18§2.5 Entity.baseTick: at the count 0 the fire is out (2 damage in 40 ticks)" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
     MOVE 18 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)

*>   A fire-immune type has its fire put out without damage.
     CALL "MOB-SPAWN" USING WS-DIM WS-PIGLIN-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW2
     CALL "STDMOB-INDEX" USING WS-PIGLIN-TYPE WS-M
     MOVE 40 TO EN-BURN(WS-ROW2)
     MOVE EN-HEALTH(WS-ROW2) TO WS-OBS
     MOVE WS-ROW2 TO WS-I
     CALL "M182-ENV-TICK" USING WS-ROW2
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a fire-immune zombified piglin has its fire cleared" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW2)
     MOVE "acceptance US15 18§2.5 Entity.baseTick: and takes no damage" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-OBS EN-HEALTH(WS-ROW2)
     CALL "ENTITY-REMOVE" USING WS-ROW2

*>   A witch's fire resistance (EN-FX-FIRE) blocks the fire damage like a fire-immune type does the burning.
     MOVE 40 TO EN-BURN(WS-ROW)
     MOVE 18 TO EN-HEALTH(WS-ROW)
     MOVE -1 TO EN-FX-FIRE(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§7.3 Damage: Fire Resistance ignores the on-fire damage" TO WS-CASE
     MOVE 18 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE 0 TO EN-FX-FIRE(WS-ROW)

*>   Water puts the fire out before it hurts.
     MOVE 40 TO EN-BURN(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a burning mob in water is put out, no damage" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
     MOVE 18 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR

*>   Lava: 4 damage, fifteen seconds of fire, the fall distance halved; a burning mob in lava takes the lava damage only.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-LAVA
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 8.0 TO EN-FALL(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: lava does 4.0 damage" TO WS-CASE
     MOVE 16 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§2.5 Entity.baseTick: lava ignites for 15 seconds (300 ticks)" TO WS-CASE
     MOVE 300 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
     MOVE "acceptance US15 18§2.5 Entity.baseTick: lava halves the fall distance" TO WS-CASE
     MOVE 4 TO WS-EXP
     MOVE EN-FALL(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: in lava the fire does no damage of its own (4, not 5)" TO WS-CASE
     MOVE 12 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§2.5 Entity.baseTick: the fire counts down, and lava raises it to 300 again" TO WS-CASE
     MOVE 300 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW)
*>   A fire-immune type in lava is not hurt and not ignited.
     CALL "MOB-SPAWN" USING WS-DIM WS-PIGLIN-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW2
     MOVE EN-HEALTH(WS-ROW2) TO WS-OBS
     CALL "M182-ENV-TICK" USING WS-ROW2
     MOVE "acceptance US15 18§2.5 Entity.baseTick: a fire-immune mob in lava takes nothing" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-OBS EN-HEALTH(WS-ROW2)
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-BURN(WS-ROW2)
     CALL "ENTITY-REMOVE" USING WS-ROW2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 0 TO EN-BURN(WS-ROW) EN-FALL(WS-ROW)

*>   Drowning: the eye in water, a cow breathes 300 ticks then 20 more below zero; then 2 damage every 20 ticks; Entity Event 67 goes with it.
     MOVE 20 TO EN-HEALTH(WS-ROW)
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WATER
     PERFORM TICK-ENV 319 TIMES
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: 319 ticks under water do no damage" TO WS-CASE
     MOVE 20 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: the 320th tick (air -20) does 2.0 drown damage" TO WS-CASE
     MOVE 18 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: and the air supply is reset to 0 (300 lost)" TO WS-CASE
     MOVE 300 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-AIR-LOST(WS-ROW)
     PERFORM TICK-ENV 19 TIMES
     MOVE 18 TO WS-EXP
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: the next damage is 20 ticks later" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     PERFORM TICK-ENV
     MOVE 16 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
*>   Out of water the air refills 4 a tick.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: out of water the air refills by 4 a tick" TO WS-CASE
     MOVE 296 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-AIR-LOST(WS-ROW)
     PERFORM TICK-ENV 74 TIMES
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: and stops at the maximum 300" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-AIR-LOST(WS-ROW)
     MOVE 16 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)

*>   A mob that breathes under water (a zombie) loses no air.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WATER
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-I WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-I WS-X WS-Y WS-Z WS-YAW WS-ROW2
     PERFORM TICK-ENV-2 10 TIMES
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: a zombie under water keeps its air" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-AIR-LOST(WS-ROW2)
     CALL "ENTITY-REMOVE" USING WS-ROW2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR

*>   In-wall damage: the head in a solid block does 1.0.
     MOVE 20 TO EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STONE
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: a head inside a solid block takes 1.0 in-wall damage" TO WS-CASE
     MOVE 19 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 LivingEntity.baseTick: in the open there is none" TO WS-CASE
     MOVE 19 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)

*>   Cramming: with the game rule 24, 25 mobs in one place: 6.0 damage on a 1 in 4 draw; with 5 mobs never; with the rule 0 never.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW2
     END-PERFORM
     MOVE 40 TO EN-HEALTH(WS-ROW)
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-I >= 200 OR EN-HEALTH(WS-ROW) < 40
         ADD 1 TO WS-I
         ADD 1 TO CW-TICKS
         MOVE 0 TO EN-HURT(WS-ROW)
         CALL "M182-ENV-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.3 Collision: 25 mobs in one place do 6.0 cramming damage" TO WS-CASE
     MOVE 34 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§3.3 Collision: the 1 in 4 draw lets it take a few ticks (not every one)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-I > 1 AND WS-I < 60
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The rule at 0 turns it off.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 40 TO EN-HEALTH(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         ADD 1 TO CW-TICKS
         MOVE 0 TO EN-HURT(WS-ROW)
         CALL "M182-ENV-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.3 Collision: max_entity_cramming 0 turns cramming off" TO WS-CASE
     MOVE 40 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
*>   A raised rule (30) is not reached by 25.
     MOVE 30 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         ADD 1 TO CW-TICKS
         MOVE 0 TO EN-HURT(WS-ROW)
         CALL "M182-ENV-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.3 Collision: max_entity_cramming 30 is not reached by 25 mobs" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE 24 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   Remove the crowd but one.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-COW-TYPE AND WS-I NOT = WS-ROW
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         ADD 1 TO CW-TICKS
         MOVE 0 TO EN-HURT(WS-ROW)
         CALL "M182-ENV-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.3 Collision: a lone mob takes no cramming damage" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)

*>   Fall damage on landing through the standard step: a cow falling 8 blocks takes floor(8 - 3) = 5; a chicken none; water softens the fall.
     MOVE 10 TO EN-HEALTH(WS-ROW)
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-Y = WS-BY + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-FALL(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.2 travel: a cow landing from 8 blocks takes 5 fall damage" TO WS-CASE
     MOVE 5 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE "acceptance US15 18§3.2 travel: the fall distance is reset on landing" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-FALL(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-CHICKEN-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.2 travel: a chicken landing from 8 blocks is unhurt" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-OBS EN-HEALTH(WS-ROW)
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WATER
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§3.2 travel: a cow falling 8 blocks into water is unhurt" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-OBS EN-HEALTH(WS-ROW)
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR

*>   A mob that dies of the fire, lava, in-wall damage or drowning ends its tick there (health 0, a dying mob: 18 section 7.5).
     PERFORM NEW-COW
     MOVE 1 TO EN-HEALTH(WS-ROW)
     MOVE 20 TO EN-BURN(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§7.5 Death: a mob on its last health point dies of the fire" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     PERFORM NEW-COW
     MOVE 1 TO EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-LAVA
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§7.5 Death: and of lava" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     PERFORM NEW-COW
     MOVE 1 TO EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STONE
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§7.5 Death: and of in-wall damage" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     PERFORM NEW-COW
     MOVE 2 TO EN-HEALTH(WS-ROW)
     MOVE 319 TO EN-AIR-LOST(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WATER
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§7.5 Death: and of drowning" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     MOVE 1.0 TO WS-DIST
     CALL "M182-FALL-DAMAGE" USING WS-DIST WS-DAMAGE
     MOVE "acceptance US15 18§3.2 travel: a fall of 1 block does no damage (never negative)" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
*>   A creeper that lands takes the fall damage too, and its swell grows by the distance (the same fall of 8 blocks: 5 damage).
     MOVE "minecraft:creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-I WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-Y = WS-BY + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-I WS-X WS-Y WS-Z WS-YAW WS-ROW2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "STDMOB-STEP" USING WS-ROW2
     END-PERFORM
     MOVE "acceptance US15 18§3.2 travel: a creeper landing from 8 blocks takes 5 fall damage" TO WS-CASE
     MOVE 15 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW2)
     CALL "ENTITY-REMOVE" USING WS-ROW2
     PERFORM NEW-COW
*>   Below the world (2.5 step 4): below the minimum y less 64 a living entity takes 4.0 damage a tick (through the hurt window), above it nothing.
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) - 70
     MOVE WS-Y TO EN-Y(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: below the world a mob takes 4.0 void damage" TO WS-CASE
     MOVE 16 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) - 60
     MOVE WS-Y TO EN-Y(WS-ROW)
     PERFORM TICK-ENV
     MOVE "acceptance US15 18§2.5 Entity.baseTick: at 60 below the minimum it does not" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     PERFORM NEW-COW
*>   Hurt-by memory (2.8): the player who hit a mob is remembered for 100 ticks; after that a death is no player kill (no experience, no killed_by_player loot).
     MOVE 40 TO EN-HEALTH(WS-ROW)
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-HIT-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§2.8 Hurt-by memory: a hit by a player is remembered" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-KILLER(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 99
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§2.8 Hurt-by memory: still remembered after 99 ticks" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-KILLER(WS-ROW)
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 18§2.8 Hurt-by memory: forgotten after 100 ticks" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-KILLER(WS-ROW)
     STOP RUN.
 NEW-COW.
     IF EN-USED(WS-ROW) = 1
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-IF
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.
 TICK-ENV.
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "M182-ENV-TICK" USING WS-ROW.
 TICK-ENV-2.
     MOVE 0 TO EN-HURT(WS-ROW2)
     CALL "M182-ENV-TICK" USING WS-ROW2.
 END PROGRAM TEST-MOB-18-2-5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
