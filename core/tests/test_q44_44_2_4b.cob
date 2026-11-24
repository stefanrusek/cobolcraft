 *> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 4, with 4.4 to 4.8): the branches of the live trial spawner that
 *> test_q44_44_2_4 leaves out. A spawner with no mob to spawn goes back to inactive from waiting_for_players and from active; spawner_blocks_work false resets the statistics of
 *> waiting_for_players; a player holding Trial Omen makes an active spawner ominous and every current mob is discarded; an ominous spawner in cooldown does not look for players; a
 *> normal one in cooldown whose detected player holds Bad Omen turns ominous and active; a type the core cannot make, a spawn cell that is not free and custom spawn rules that do not hold
 *> each spawn nothing, rules that hold do; the reward ejection rolls its table (loot tables of core/tests/fixtures/loot-trial) and drops the items, the run keeping the table it chose.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-4B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CONTENT.
 COPY BRWORLD.
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
 01 WS-S                   BINARY-DOUBLE.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 90000.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-BAD                 BINARY-LONG VALUE 30.
 01 WS-TRIAL               BINARY-LONG VALUE 33.
 01 WS-KIND-STATE          BINARY-LONG VALUE 1.
 01 WS-KIND-OMINOUS        BINARY-LONG VALUE 2.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/loot-trial".
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-KEYS                BINARY-LONG.
 01 WS-CONS                BINARY-LONG.
 01 WS-ROUNDS              BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
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
     MOVE "minecraft:zombie" TO WS-ID
     MOVE 16 TO WS-LEN
     MOVE WS-T0 TO CW-TICKS
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4 Trial spawner: an overridden spawner waits for players" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N

*>   spawner_blocks_work false in waiting_for_players: the statistics are reset
     MOVE 1 TO BE-XI(WS-BE, 1)
     MOVE 3 TO BE-XI(WS-BE, 3)
     MOVE "spawner_blocks_work" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "BE-TICK-ALL"
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.4 waiting_for_players with spawner_blocks_work false resets the statistics and stays" TO WS-CASE
     MOVE 1000 TO WS-E
     COMPUTE WS-O = WS-ST * 1000 + BE-XI(WS-BE, 1) * 100 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N

*>   no mob to spawn: waiting_for_players returns to inactive
     MOVE 0 TO BE-XI(WS-BE, 5) BE-XI(WS-BE, 17)
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.4 waiting_for_players with no mob to spawn becomes inactive" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N

*>   active, then no mob to spawn: inactive
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.4 a player in range on a scan tick makes the spawner active" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO BE-XI(WS-BE, 5) BE-XI(WS-BE, 17)
     COMPUTE CW-TICKS = WS-T0 + 1
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.4 active with no mob to spawn becomes inactive" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ST TO WS-O
     PERFORM CHECK-N

*>   a player with Trial Omen: an active spawner with a mob alive turns ominous and discards the mob
     MOVE WS-T0 TO CW-TICKS
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     COMPUTE CW-TICKS = WS-T0 + 41
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR BE-XI(WS-BE, 3) = 1
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-2§4.7 an active spawner has spawned one zombie (current_mobs 1)" TO WS-CASE
     MOVE 101 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 100 + BE-XI(WS-BE, 2)
     PERFORM CHECK-N
     CALL "EFFECT-ADD" USING WS-PLAYER WS-TRIAL WS-AMP WS-DURATION WS-FLAGS
     COMPUTE CW-TICKS = WS-T0 + 60
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-2§4.6 a player with Trial Omen turns an active spawner ominous" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OM TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4.6 and the current mobs are discarded: no zombie, current_mobs and total_mobs_spawned 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 10000 + BE-XI(WS-BE, 2) * 100 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N

*>   an ominous spawner in cooldown does not look for players
     MOVE 0 TO BE-XI(WS-BE, 1)
     COMPUTE BE-SEED(WS-BE) = WS-T0 + 900000
     MOVE 5 TO WS-VALUE
     CALL "TS-STATE-SET" USING WS-DIM WS-SX WS-SY WS-SZ WS-KIND-STATE WS-VALUE
     COMPUTE CW-TICKS = WS-T0 + 80
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.5 an ominous spawner in cooldown detects nobody and stays in cooldown" TO WS-CASE
     COMPUTE WS-E = 5 * 10 + 0
     COMPUTE WS-O = WS-ST * 10 + BE-XI(WS-BE, 1)
     PERFORM CHECK-N

*>   a normal spawner in cooldown whose detected player holds Bad Omen turns ominous and active
     MOVE 0 TO WS-VALUE
     CALL "TS-STATE-SET" USING WS-DIM WS-SX WS-SY WS-SZ WS-KIND-OMINOUS WS-VALUE
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-TRIAL
     CALL "EFFECT-ADD" USING WS-PLAYER WS-BAD WS-AMP WS-DURATION WS-FLAGS
     COMPUTE CW-TICKS = WS-T0 + 100
     CALL "BE-TICK-ALL"
     PERFORM GET-STATE
     MOVE "acceptance US15 44-2§4.4 a normal spawner in cooldown with a Bad Omen player detected turns ominous and goes back to active" TO WS-CASE
     MOVE 21 TO WS-E
     COMPUTE WS-O = WS-ST * 10 + WS-OM
     PERFORM CHECK-N
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-TRIAL

*>   a type the core cannot make is never spawned
     MOVE "minecraft:armor_stand" TO WS-ID
     MOVE 21 TO WS-LEN
     MOVE 0 TO WS-VALUE
     CALL "TS-STATE-SET" USING WS-DIM WS-SX WS-SY WS-SZ WS-KIND-OMINOUS WS-VALUE
     COMPUTE CW-TICKS = WS-T0 + 120
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     COMPUTE CW-TICKS = WS-T0 + 161
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM GET-STATE
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 44-2§4.7 an entity type the core cannot make is not spawned (active, no mob, none spawned)" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O = WS-ST * 100 + WS-ZOMBIES * 10 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N

*>   the cells of the spawn range are solid: no mob
     MOVE "minecraft:zombie" TO WS-ID
     MOVE 16 TO WS-LEN
     COMPUTE CW-TICKS = WS-T0 + 200
     CALL "TS-OVERRIDE" USING WS-BE WS-ID WS-LEN
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     PERFORM FILL-STONE
     COMPUTE CW-TICKS = WS-T0 + 241
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 44-2§4.7 with every cell of the spawn range solid no mob is spawned" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 10 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N
     PERFORM CLEAR-STONE

*>   free cells but a ring of stone around the spawner and a cap over it: the visual ray from the block to the cell is blocked, no mob
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 1
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 3
                 IF WS-X NOT = 0 OR WS-Z NOT = 0 OR WS-Y > 0
                     COMPUTE WS-X0 = WS-SX + WS-X
                     COMPUTE WS-Z0 = WS-SZ + WS-Z
                     COMPUTE WS-Y0 = WS-SY + WS-Y
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-STONE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE CW-TICKS = WS-T0 + 300
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 44-2§4.7 free cells behind a ring of stone have no line of sight from the block: no mob is spawned" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 10 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 1
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 3
                 IF WS-X NOT = 0 OR WS-Z NOT = 0 OR WS-Y > 0
                     COMPUTE WS-X0 = WS-SX + WS-X
                     COMPUTE WS-Z0 = WS-SZ + WS-Z
                     COMPUTE WS-Y0 = WS-SY + WS-Y
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-AIR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>   custom spawn rules that do not hold (block light 15 only), then rules that hold
     MOVE 1 TO BE-XI(WS-BE, 16)
     MOVE 15 TO BE-XI(WS-BE, 12)
     MOVE 15 TO BE-XI(WS-BE, 13)
     MOVE 0 TO BE-XI(WS-BE, 14)
     MOVE 15 TO BE-XI(WS-BE, 15)
     COMPUTE CW-TICKS = WS-T0 + 400
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 44-2§4.7 custom spawn rules whose block light range (15) does not hold spawn nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 10 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N
     MOVE 0 TO BE-XI(WS-BE, 12)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR BE-XI(WS-BE, 3) = 1
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 44-2§4.7 custom spawn rules whose ranges hold (block 0 to 15, sky 0 to 15) let the zombie spawn" TO WS-CASE
     MOVE 11 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES * 10 + BE-XI(WS-BE, 3)
     PERFORM CHECK-N

*>   the reward ejection: the table rolls and drops items, the run keeps the table it chose; both tables of the default list come up over many runs
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE "acceptance US15 44-2§4.8 the loot table fixture loads" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-KEYS WS-CONS WS-ROUNDS WS-EMPTY
     MOVE 36000 TO BE-XI(WS-BE, 9)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         COMPUTE WS-S = WS-T0 + 2000 * WS-I
         COMPUTE BE-SEED(WS-BE) = WS-S + 36000
         MOVE 4 TO WS-VALUE
         CALL "TS-STATE-SET" USING WS-DIM WS-SX WS-SY WS-SZ WS-KIND-STATE WS-VALUE
         MOVE 1 TO BE-XI(WS-BE, 1)
         MOVE 0 TO BE-XI(WS-BE, 6)
         PERFORM COUNT-ENTITIES
         MOVE WS-AFTER TO WS-BEFORE
         COMPUTE CW-TICKS = WS-S + 60
         CALL "BE-TICK-ALL"
         PERFORM COUNT-ENTITIES
         IF WS-AFTER > WS-BEFORE
             ADD 1 TO WS-ROUNDS
         END-IF
         IF BE-XI(WS-BE, 6) = 37 AND BE-XT(WS-BE, 2)(1:37) = "minecraft:spawners/trial_chamber/key"
             ADD 1 TO WS-KEYS
         END-IF
         IF BE-XI(WS-BE, 6) = 44 AND BE-XT(WS-BE, 2)(1:44) = "minecraft:spawners/trial_chamber/consumables"
             ADD 1 TO WS-CONS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-2§4.8 every ejection drops at least one item entity" TO WS-CASE
     MOVE 30 TO WS-E
     MOVE WS-ROUNDS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§4.8 over 30 runs each of the two tables of the default list was chosen and every run kept one of them" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-KEYS > 0 AND WS-CONS > 0 AND WS-KEYS + WS-CONS = 30
         MOVE 1 TO WS-O
     END-IF
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
 COUNT-MOBS.
*>   every entity but the player (a type the core cannot make leaves none)
     MOVE 0 TO WS-ZOMBIES
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0
             ADD 1 TO WS-ZOMBIES
         END-IF
     END-PERFORM.
 COUNT-ENTITIES.
     MOVE 0 TO WS-AFTER
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1
             ADD 1 TO WS-AFTER
         END-IF
     END-PERFORM.
 FILL-STONE.
     COMPUTE WS-X0 = WS-SX - 5
     COMPUTE WS-X1 = WS-SX + 5
     COMPUTE WS-Z0 = WS-SZ - 5
     COMPUTE WS-Z1 = WS-SZ + 5
     COMPUTE WS-Y0 = WS-SY - 1
     COMPUTE WS-Y1 = WS-SY + 3
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
                 IF WS-X NOT = WS-SX OR WS-Z NOT = WS-SZ OR WS-Y NOT = WS-SY
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 CLEAR-STONE.
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
                 IF WS-X NOT = WS-SX OR WS-Z NOT = WS-SZ OR WS-Y NOT = WS-SY
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-2-4B.
 COPY CORETEST.
 COPY MOBSPTEST.
