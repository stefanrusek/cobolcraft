*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 5): spawn eggs. An egg used on a block makes the mob with a random yaw
*> (wrapDegrees(nextFloat x 360), pitch 0). On a spawner the egg fails with advMode.notEnabled.spawner when spawner_blocks_work is false and keeps the stack; otherwise a mob spawner takes the
*> species and a trial spawner is overridden (state reset, the entity its only potential, inactive), and the stack shrinks even for a creative player (ItemStack.shrink has no infinite-materials
*> test), while an egg on an ordinary block is kept by a creative player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BESTATE.
 COPY PLAYPKT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-BE                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-LOW                 FLOAT-SHORT.
 01 WS-HIGH                FLOAT-SHORT.
 01 WS-INRANGE             BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-RULE-NAME           PIC X(40) VALUE "spawner_blocks_work".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-ST                  BINARY-LONG.
 01 WS-OM                  BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-HELD(WS-PLAYER) TO WS-HELD
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 3
     MOVE WS-FY TO WS-BY
     MOVE FUNCTION INTEGER(WS-Z) TO WS-BZ
     MOVE 0 TO PSB-HAND
     MOVE WS-BX TO PSB-BX
     MOVE WS-BY TO PSB-BY
     MOVE WS-BZ TO PSB-BZ
     MOVE 1 TO PSB-FACE
     MOVE "minecraft:cow_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   twelve eggs on the block: yaws within [-180, 180) and not all the same
     MOVE 1000 TO WS-LOW
     MOVE -1000 TO WS-HIGH
     MOVE 1 TO WS-INRANGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
         CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
         PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > EN-COUNT
             IF EN-USED(WS-COUNT) = 1 AND EN-TYPE(WS-COUNT) = WS-COW-TYPE
                 IF EN-YAW(WS-COUNT) < WS-LOW
                     MOVE EN-YAW(WS-COUNT) TO WS-LOW
                 END-IF
                 IF EN-YAW(WS-COUNT) > WS-HIGH
                     MOVE EN-YAW(WS-COUNT) TO WS-HIGH
                 END-IF
                 IF EN-YAW(WS-COUNT) < -180 OR EN-YAW(WS-COUNT) >= 180
                     MOVE 0 TO WS-INRANGE
                 END-IF
                 CALL "ENTITY-REMOVE" USING WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 44-2§5 Spawn egg: every yaw is wrapDegrees(nextFloat x 360), within -180 to 180" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-INRANGE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: the yaws of twelve eggs differ (spread over more than 90 degrees)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HIGH - WS-LOW > 90
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   a creative player keeps the egg on a block
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 44-2§5 Spawn egg: a creative player keeps the egg used on an ordinary block" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
*>   on a mob spawner with spawner_blocks_work false: fails with the message, the stack and the spawner stay
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 44-2§5 Spawn egg: on a spawner with spawner_blocks_work false the egg is not handled (done 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: and the stack keeps its 2 eggs" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: and the spawner has no species" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BE-XI(WS-BE, 8) TO WS-O
     PERFORM CHECK-N
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-TALLY
     INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL "advMode.notEnabled.spawner"
     MOVE "acceptance US15 44-2§5 Spawn egg: and the player is told advMode.notEnabled.spawner" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-TALLY, 1) TO WS-O
     PERFORM CHECK-N
*>   the rule on: the spawner takes the cow, the egg is used up
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 44-2§5 Spawn egg: on a spawner with the rule on the egg is handled and the spawner holds the cow" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DONE = 1 AND BE-XT(WS-BE, 1) = "minecraft:cow" AND BE-XI(WS-BE, 8) = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: and one egg is used up (1 left)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
*>   a creative player's egg on a spawner is used up all the same (ItemStack.shrink)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 44-2§5 Spawn egg: a creative player's egg on a spawner is used up (shrink has no infinite-materials test)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   a trial spawner: overridden with the zombie, inactive, state reset
     MOVE "minecraft:trial_spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 3 TO BE-XI(WS-BE, 3)
     MOVE 1 TO BE-XI(WS-BE, 2)
     MOVE 1 TO BE-XI(WS-BE, 1)
     MOVE 777 TO BE-TIME2(WS-BE)
     MOVE "minecraft:zombie_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     CALL "TS-STATE-GET" USING WS-DIM WS-BX WS-BY WS-BZ WS-ST WS-OM
     MOVE "acceptance US15 44-2§5 Spawn egg: on a trial spawner the egg is handled, one is used up, the state is inactive" TO WS-CASE
     COMPUTE WS-E = 1 * 1000 + 1 * 10 + 0
     COMPUTE WS-O = WS-DONE * 1000 + PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) * 10 + WS-ST
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: overrideEntityToSpawn clears current mobs, total_mobs_spawned, players and next_mob_spawns_at" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = BE-XI(WS-BE, 1) + BE-XI(WS-BE, 2) + BE-XI(WS-BE, 3) + BE-TIME2(WS-BE)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§5 Spawn egg: and the potentials are the zombie alone, with no next spawn data yet" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE, 17) = 1 AND BE-XT(WS-BE, 5) = "minecraft:zombie" AND BE-XI(WS-BE, 18) = 16 AND BE-XI(WS-BE, 5) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   the same with the rule off fails
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 44-2§5 Spawn egg: on a trial spawner with spawner_blocks_work false the egg fails and stays (done 0, 1 left)" TO WS-CASE
     COMPUTE WS-E = 0 * 10 + 1
     COMPUTE WS-O = WS-DONE * 10 + PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-2-5.
 COPY CORETEST.
 COPY MOBSPTEST.
