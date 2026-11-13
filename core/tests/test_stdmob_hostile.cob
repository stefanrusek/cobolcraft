*> Implementation test (002-lane-mobs, T4004; docs/protocol/20 sections 3.1, 3.3, 3.5 and 4.1, 18 sections 4.2 and 7.3): the zombie of a standard world.
*> It is row 6 of core/copy/STDMOBS.cpy (health 20, attack 3, follow range 35, burns in daylight). A player within the follow range that is in survival is its
*> target; it walks to the player and, in melee range with its attack timer at 0, hits (HEALTH-MOB-HIT: the difficulty scaling of 20 section 3.1, armor,
*> CAUSE-MOB, the vanilla message death.attack.mob), the timer becoming 20. In daylight under open sky it catches fire and takes 1 damage a second.
*> Hostile mobs spawn on solid ground in the dark (STDMOB-SPAWN-HOSTILE).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-HOSTILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY RULES.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-SPAWNS              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-HEALTH-TENTHS       BINARY-LONG.
 01 WS-DIR                PIC X(1100).
 01 WS-TYPE               BINARY-LONG.
 01 WS-TIME-ARG           BINARY-DOUBLE.
 01 WS-DAY                 BINARY-DOUBLE VALUE 6000.
 01 WS-NIGHT               BINARY-DOUBLE VALUE 18000.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z

     MOVE "N" TO TL-MODE
     MOVE "test stdmob hostile: the zombie is row 6 with 20 health" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO TL-EXPECTED-N
     CALL "STDMOB-HEALTH" USING WS-ZOMBIE-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE "test stdmob hostile: a zombie has 20 health" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Chase: a zombie 6 blocks east of the player walks toward the player.
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     MOVE "test stdmob hostile: a zombie walks toward a player within its follow range" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-X(WS-ZOMBIE) < WS-X0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A player in creative is no target: the zombie does not close in.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE EN-X(WS-ZOMBIE) TO WS-X0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     MOVE "test stdmob hostile: a target that turns creative is dropped and none is taken" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF EN-TARGET(WS-ZOMBIE) = 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   Attack: next to the player, one hit of 3 at Normal, then the attack timer 20.
     COMPUTE WS-X0 = WS-X + 0.9
     MOVE WS-X0 TO EN-X(WS-ZOMBIE)
     MOVE WS-Y TO EN-Y(WS-ZOMBIE)
     MOVE WS-Z TO EN-Z(WS-ZOMBIE)
     MOVE 0 TO EN-COOLDOWN(WS-ZOMBIE) EN-TARGET(WS-ZOMBIE)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "MOB-STEP" USING WS-ZOMBIE
     COMPUTE WS-HEALTH-TENTHS = PL-HEALTH(WS-PLAYER) * 10
     MOVE "N" TO TL-MODE
     MOVE "test stdmob hostile: a zombie in melee range hits for 3 at Normal" TO TL-CASE
     MOVE 170 TO TL-EXPECTED-N
     MOVE WS-HEALTH-TENTHS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob hostile: the attack timer is 20 after a hit" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-COOLDOWN(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-ZOMBIE
     MOVE "test stdmob hostile: the timer counts down and there is no second hit" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE EN-COOLDOWN(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Difficulty scaling (20 section 3.1) through HEALTH-MOB-HIT: Peaceful 0, Easy min(d / 2 + 1, d), Normal d, Hard 3d / 2.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
         MOVE WS-J TO BW-DIFFICULTY
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-AMOUNT WS-ZOMBIE
         COMPUTE WS-HEALTH-TENTHS = PL-HEALTH(WS-PLAYER) * 10
         EVALUATE WS-J
             WHEN 0
                 MOVE "test stdmob hostile: Peaceful, a mob hit does nothing" TO TL-CASE
                 MOVE 200 TO TL-EXPECTED-N
             WHEN 1
                 MOVE "test stdmob hostile: Easy, a hit of 3 is 2.5" TO TL-CASE
                 MOVE 175 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "test stdmob hostile: Normal, a hit of 3 is 3" TO TL-CASE
                 MOVE 170 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "test stdmob hostile: Hard, a hit of 3 is 4.5" TO TL-CASE
                 MOVE 155 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-HEALTH-TENTHS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 2 TO BW-DIFFICULTY

*>   The damage type of CAUSE-MOB: RULES.cpy's 28 in a cobolcraft set (the registry of the world opened by this test is the cobolcraft one).
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MOB WS-INDEX
     MOVE "test stdmob hostile: the damage type of CAUSE-MOB in a cobolcraft set is 28" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

*>   A lethal mob hit: the player is dead, by CAUSE-MOB, the killer named after the mob.
     MOVE 2 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-AMOUNT WS-ZOMBIE
     MOVE "test stdmob hostile: a lethal hit kills with CAUSE-MOB" TO TL-CASE
     MOVE CAUSE-MOB TO TL-EXPECTED-N
     MOVE PL-DEATH-CAUSE(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob hostile: the killer is named Zombie" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Zombie" TO TL-EXPECTED
     MOVE PL-KILLER-NAME(WS-PLAYER) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The generated terrain of the test world holds cobolcraft block states that a standard table does not know as solid, so a stone floor is set
*>   under the zombie first.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE-STATE
     COMPUTE WS-Y = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
*>   Daylight: a zombie standing in the open by day catches fire and loses health; by night it does not.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE WS-DAY TO CW-TIME
     MOVE WS-X TO EN-X(WS-ZOMBIE)
     MOVE WS-Y TO EN-Y(WS-ZOMBIE)
     MOVE WS-Z TO EN-Z(WS-ZOMBIE)
     MOVE 20 TO EN-HEALTH(WS-ZOMBIE)
     MOVE 0 TO EN-BURN(WS-ZOMBIE) EN-HURT(WS-ZOMBIE) EN-TARGET(WS-ZOMBIE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 700
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     MOVE "test stdmob hostile: a zombie in daylight loses health to fire" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-ZOMBIE) < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-NIGHT TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 700
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     MOVE "test stdmob hostile: a zombie at night keeps its 20 health" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The zombie burns to death in enough daylight (700 ticks lose health, 3000 more kill it).
     MOVE WS-DAY TO CW-TIME
     MOVE 20 TO EN-HEALTH(WS-ZOMBIE)
     MOVE 0 TO EN-BURN(WS-ZOMBIE) EN-HURT(WS-ZOMBIE) EN-COOLDOWN(WS-ZOMBIE)
     MOVE WS-X TO EN-X(WS-ZOMBIE)
     MOVE WS-Y TO EN-Y(WS-ZOMBIE)
     MOVE WS-Z TO EN-Z(WS-ZOMBIE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR EN-HEALTH(WS-ZOMBIE) = 0
         ADD 1 TO CW-TIME
         MOVE WS-X TO EN-X(WS-ZOMBIE)
         MOVE WS-Y TO EN-Y(WS-ZOMBIE)
         MOVE WS-Z TO EN-Z(WS-ZOMBIE)
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     MOVE "test stdmob hostile: a zombie left in daylight burns to death" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The night's darkening of the sky light (12 section 3.2 D4): 0 by day, a ramp at dusk, 11 in the dark, a ramp at dawn.
     MOVE 6000 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: no darkening at tick 6000" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12000 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: darkening 4 at tick 12000 (dusk ramp)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: darkening 11 at tick 18000" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23500 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: darkening 7 at tick 23500 (dawn ramp)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: darkening 3 at tick 100 (the dawn ramp past midnight)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO WS-TIME-ARG
     CALL "STDMOB-DARKEN" USING WS-TIME-ARG WS-INDEX
     MOVE "test stdmob hostile: no darkening at tick 1000" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Peaceful removes hostile mobs on the mob tick.
     MOVE 0 TO BW-DIFFICULTY
     CALL "MOBS-TICK"
     MOVE "test stdmob hostile: Peaceful removes the zombie" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-ZOMBIE) = 1 AND EN-TYPE(WS-ZOMBIE) = WS-ZOMBIE-TYPE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO BW-DIFFICULTY

*>   Spawning in the dark (20 section 3.3): a stone floor high above the terrain, open air above it.
     COMPUTE WS-TOP = FUNCTION INTEGER(WS-Y) + 40
     PERFORM VARYING WS-BY FROM WS-TOP BY 1 UNTIL WS-BY > WS-TOP + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-TOP WS-BZ WS-STONE-STATE
*>   By day (sky light 15) no attempt in 200 spawns a zombie; at night under the open sky some do.
     MOVE WS-DAY TO CW-TIME
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 199
         CALL "STDMOB-SPAWN-HOSTILE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "test stdmob hostile: no zombie spawns on open ground by day" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-NIGHT TO CW-TIME
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 199
         CALL "STDMOB-SPAWN-HOSTILE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "test stdmob hostile: zombies spawn on open ground at night" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > WS-BEFORE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A lit spot is no spawn spot: a glowstone beside the floor's cell gives block light there, and no attempt spawns a zombie.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:glowstone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BY = WS-TOP + 1
     COMPUTE WS-BX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE-STATE
     COMPUTE WS-BX = WS-BX - 1
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 199
         CALL "STDMOB-SPAWN-HOSTILE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "test stdmob hostile: no zombie spawns on a cell with block light" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   In a standard set the id is the position of minecraft:mob_attack in the damage_type registry: the fixture set has generic (0) and mob_attack (1).
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "core/tests/fixtures/stdmob-content" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MOB WS-INDEX
     MOVE "test stdmob hostile: the damage type of CAUSE-MOB in a standard set is the registry position of mob_attack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-PLAYER WS-INDEX
     MOVE "test stdmob hostile: the older causes keep the RULES.cpy ids (29 for the player's attack)" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 COUNT-ZOMBIES.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > EN-COUNT
         IF EN-USED(WS-INDEX) = 1 AND EN-TYPE(WS-INDEX) = WS-ZOMBIE-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STDMOB-HOSTILE.
 COPY CORETEST.
