*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 4, with 14.2 and 14.3): the trial spawner in the live world. A spawner whose
*> configurations were overridden with one entity (the egg of section 5) runs the state machine of 4.4: inactive, waiting_for_players, active, waiting_for_reward_ejection, ejecting_reward and
*> cooldown, with player detection (4.5: the scan tick, creative and spectator players, the line of sight, Bad Omen making it ominous), mob spawning (4.7), the simultaneous cap, lost mobs and the
*> 30 tick ejection of one reward per detected player. The default configuration is used (total 6 and +2 a player, simultaneous 2 and +1, 40 ticks between spawns, cooldown 36000).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY LOOTCTX.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-OM                  BINARY-LONG.
 01 WS-ZOMBIES             BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 2.
 01 WS-DURATION            BINARY-LONG VALUE 5000.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-BAD                 BINARY-LONG VALUE 30.
 01 WS-TRIAL               BINARY-LONG VALUE 33.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-LONGKEY             PIC X(112).
 01 WS-IDS                 PIC X(1024).
 01 WS-TALLY               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 30
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 30
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE "minecraft:trial_spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-SY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-SX WS-SY WS-SZ WS-BE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO CW-GAME-TIME
     CALL "BE7-PACK-POS" USING WS-SX WS-SY WS-SZ WS-PACKED
     COMPUTE WS-T0 = 1000 + FUNCTION MOD(20 - FUNCTION MOD(WS-PACKED, 20), 20)
*>   without potentials the spawner has no mob to spawn: it stays inactive
     MOVE WS-T0 TO CW-TICKS
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a spawner with no spawn potentials has no mob to spawn and stays inactive" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
*>   a spawn egg's override: one potential entity, inactive; the next tick waits for players with that entity as the next spawn data
     MOVE "minecraft:zombie" TO WS-ID
     MOVE 16 TO WS-LEN
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: overrideEntityToSpawn leaves the block state inactive" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: inactive with a mob to spawn becomes waiting_for_players" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: and the next spawn data holds the zombie" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE, 4) = 1 AND BE-XT(WS-BE, 1) = "minecraft:zombie" AND BE-XI(WS-BE, 5) = 16
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   a tick that is not a scan tick detects nobody
     COMPUTE CW-TICKS = WS-T0 + 1
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a player is only looked for on scan ticks ((packed position + game time) mod 20 is 0)" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-ST * 10 + BE-XI(WS-BE, 1)
     MOVE 10 TO WS-E
     PERFORM CHECK-N
*>   creative and spectator players are not detected
     MOVE WS-T0 TO CW-TICKS
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a creative player is not detected" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a spectator is not detected" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   a wall between the player and the block: no line of sight, not detected
     PERFORM BUILD-WALL
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a wall in the visual ray keeps a player from being detected" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     PERFORM REMOVE-WALL
*>   a player out of range
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) + 20
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a player 20 blocks away (range 14) is not detected" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) - 20
*>   the scan tick with a player in sight: detected, active, next_mob_spawns_at at least 40 ticks on
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: a player in range and in sight on a scan tick is detected and the state becomes active" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: the detected set holds one player and next_mob_spawns_at is game time + 40" TO WS-CASE
     COMPUTE WS-E = 1 * 1000000 + WS-T0 + 40
     COMPUTE WS-O = BE-XI(WS-BE, 1) * 1000000 + BE-TIME2(WS-BE)
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE 0 TO WS-TALLY
     IF WS-IDS = "47"
         MOVE 1 TO WS-TALLY
     END-IF
     MOVE "acceptance US15 44-2§4 Trial spawner: the detection sends level event 3013 (exactly one Level Event packet, id 47, reaches the player)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-TALLY, 1) TO WS-O
     PERFORM CHECK-N
*>   active, before next_mob_spawns_at: nothing spawns
     COMPUTE CW-TICKS = WS-T0 + 39
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-2§4 Trial spawner: before next_mob_spawns_at no mob is spawned" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ZOMBIES TO WS-O
     PERFORM CHECK-N
*>   at game time + 40 the first mob is spawned (an attempt that finds no place is repeated on the next tick)
     COMPUTE CW-TICKS = WS-T0 + 41
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR BE-XI(WS-BE, 3) = 1
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-2§4 Trial spawner: a due spawn makes one zombie, counted in total_mobs_spawned and current_mobs" TO WS-CASE
     COMPUTE WS-E = 1 * 10000 + 1 * 100 + 1
     COMPUTE WS-O = WS-ZOMBIES * 10000 + BE-XI(WS-BE, 3) * 100 + BE-XI(WS-BE, 2)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: next_mob_spawns_at is the game time + ticks_between_spawn (40)" TO WS-CASE
     COMPUTE WS-E = WS-T0 + 81
     MOVE BE-TIME2(WS-BE) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: the spawned mob is persistent" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ZTYPE AND EN-PERSISTENT(WS-J) = 1
             MOVE 1 TO WS-O
         END-IF
     END-PERFORM
     PERFORM CHECK-N
*>   the second mob a spawn later; a third waits for the simultaneous cap of 2 (one player)
     COMPUTE CW-TICKS = WS-T0 + 121
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR BE-XI(WS-BE, 3) = 2
         CALL "BE-TICK-ALL"
     END-PERFORM
     COMPUTE CW-TICKS = WS-T0 + 200
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-2§4 Trial spawner: with one player at most 2 mobs live at once (target simultaneous 2): two zombies, 2 spawned" TO WS-CASE
     COMPUTE WS-E = 2 * 100 + 2
     COMPUTE WS-O = WS-ZOMBIES * 100 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N
*>   a mob that died leaves current_mobs and delays the next spawn by 40 ticks
     MOVE 0 TO WS-X
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ZTYPE AND WS-X = 0
             MOVE 1 TO WS-X
             CALL "ENTITY-REMOVE" USING WS-J
         END-IF
     END-PERFORM
     COMPUTE CW-TICKS = WS-T0 + 300
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§4 Trial spawner: a mob that is gone is dropped from current_mobs" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE BE-XI(WS-BE, 2) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: and next_mob_spawns_at is set to game time + 40" TO WS-CASE
     COMPUTE WS-E = WS-T0 + 340
     MOVE BE-TIME2(WS-BE) TO WS-O
     PERFORM CHECK-N
*>   a mob more than 47 blocks away is untracked too
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ZTYPE
             COMPUTE EN-X(WS-J) = EN-X(WS-J) + 48
         END-IF
     END-PERFORM
     COMPUTE CW-TICKS = WS-T0 + 301
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§4 Trial spawner: a mob more than 47 blocks from the spawner is no longer tracked" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BE-XI(WS-BE, 2) TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ZTYPE
             CALL "ENTITY-REMOVE" USING WS-J
         END-IF
     END-PERFORM
*>   spawner_blocks_work false: active goes back to waiting_for_players
     MOVE "spawner_blocks_work" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: with spawner_blocks_work false an active spawner resets its statistics and waits for players" TO WS-CASE
     COMPUTE WS-E = 1 * 1000 + 0
     COMPUTE WS-O = WS-ST * 1000 + BE-XI(WS-BE, 1) * 100 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   Peaceful: canSpawnInLevel is false
     MOVE WS-T0 TO CW-TICKS
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE 0 TO BW-DIFFICULTY
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§4 Trial spawner: Peaceful (canSpawnInLevel false) sends an active spawner back to waiting_for_players" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM GET-STATE
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
*>   the total reached with no mob alive: waiting_for_reward_ejection, cooldown_ends_at = time + 36000
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE 6 TO BE-XI(WS-BE, 3)
     MOVE 0 TO BE-XI(WS-BE, 2)
     COMPUTE CW-TICKS = WS-T0 + 400
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: total_mobs_spawned at the target (6) and no mob alive: waiting_for_reward_ejection" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: cooldown_ends_at is game time + 36000, the counters are reset" TO WS-CASE
     COMPUTE WS-E = WS-T0 + 400 + 36000
     MOVE BE-SEED(WS-BE) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: total_mobs_spawned and next_mob_spawns_at are 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = BE-XI(WS-BE, 3) + BE-TIME2(WS-BE)
     PERFORM CHECK-N
*>   the shutter opens 40 ticks after the start
     COMPUTE CW-TICKS = WS-T0 + 400 + 39
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: 39 ticks after the last mob the spawner still waits for the reward ejection" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     COMPUTE CW-TICKS = WS-T0 + 400 + 40
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: at start + 40 it becomes ejecting_reward" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
*>   ejecting: only on ticks with (time - start) mod 30 = 0; one player is detected (set to 1 here)
     MOVE 1 TO BE-XI(WS-BE, 1)
     COMPUTE CW-TICKS = WS-T0 + 400 + 41
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§4 Trial spawner: on a tick whose offset from the start is not a multiple of 30 nothing is ejected" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     COMPUTE CW-TICKS = WS-T0 + 400 + 60
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§4 Trial spawner: at start + 60 the reward of the player is ejected and the player leaves the set" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: the ejection run keeps one loot table (a key of the default list) in ejecting_loot_table" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE, 6) > 0
         IF BE-XT(WS-BE, 2)(1:BE-XI(WS-BE, 6)) = "minecraft:spawners/trial_chamber/key" OR BE-XT(WS-BE, 2)(1:BE-XI(WS-BE, 6)) = "minecraft:spawners/trial_chamber/consumables"
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: it is still ejecting_reward until a 30 tick finds no player" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     COMPUTE CW-TICKS = WS-T0 + 400 + 90
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: at start + 90 with no player left it closes the shutter and the state is cooldown" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: the ejecting loot table is cleared" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BE-XI(WS-BE, 6) TO WS-O
     PERFORM CHECK-N
*>   cooldown: a normal spawner that did not become ominous looks for nobody; at cooldown_ends_at it resets
     COMPUTE CW-TICKS = WS-T0 + 400 + 36000 - 20
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: before cooldown_ends_at the spawner stays in cooldown" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     COMPUTE CW-TICKS = WS-T0 + 400 + 36000
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: at cooldown_ends_at it resets to waiting_for_players" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
*>   14.3: a player with Bad Omen (amplifier 2) makes the spawner ominous on the scan tick
     CALL "EFFECT-ADD" USING WS-PLAYER WS-BAD WS-AMP WS-DURATION WS-FLAGS
     COMPUTE WS-T = WS-T0 + 40000
     MOVE WS-T TO CW-TICKS
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: 14.3 a Bad Omen player on a scan tick makes the spawner ominous (block property ominous true)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OM TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: and the state is active (the player is detected)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-TRIAL WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-2§4 Trial spawner: 14.3 Bad Omen amplifier 2 became Trial Omen of (2 + 1) x 18000 = 54000 ticks, amplifier 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-LEVEL = 1 AND WS-TICKS = 54000
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-BAD WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-2§4 Trial spawner: and the Bad Omen is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LEVEL TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4 Trial spawner: 14.3 next_mob_spawns_at = now + ominous.ticks_between_spawn (the detection adds the 40 tick delay after it) and cooldown_ends_at = now + 160" TO WS-CASE
     COMPUTE WS-E = (WS-T + 40) * 100000 + WS-T + 160
     COMPUTE WS-O = BE-TIME2(WS-BE) * 100000 + BE-SEED(WS-BE)
     PERFORM CHECK-N
     STOP RUN.
 GET-STATE.
     CALL "TS-STATE-GET" USING WS-DIM WS-SX WS-SY WS-SZ WS-ST WS-OM.
 COUNT-ZOMBIES.
     MOVE 0 TO WS-ZOMBIES
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ZTYPE
             ADD 1 TO WS-ZOMBIES
         END-IF
     END-PERFORM.
 BUILD-WALL.
     COMPUTE WS-Z = WS-SZ - 2
     COMPUTE WS-X0 = WS-SX - 2
     COMPUTE WS-X1 = WS-SX + 2
     COMPUTE WS-Y0 = WS-FY + 1
     COMPUTE WS-Y1 = WS-FY + 6
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
         END-PERFORM
     END-PERFORM.
 REMOVE-WALL.
     COMPUTE WS-Z = WS-SZ - 2
     COMPUTE WS-X0 = WS-SX - 2
     COMPUTE WS-X1 = WS-SX + 2
     COMPUTE WS-Y0 = WS-FY + 1
     COMPUTE WS-Y1 = WS-FY + 6
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
         END-PERFORM
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-2-4.
 COPY CORETEST.
 COPY MOBSPTEST.
