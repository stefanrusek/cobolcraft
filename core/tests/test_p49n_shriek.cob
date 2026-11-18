*> Implementation test (002-lane-p49n; docs/protocol/44-residual-mob-questions-x2 section 2, 20 section 15): the sculk shrieker and the warden spawn tracker.
*> The tracker (KK-WARD-* of the known row): +1 tick a tick, the level falls after 12000, the cooldown counts down (2.1); tryWarn picks the highest level among the players within 16 blocks,
*> refuses with a cooldown or a warden within the 48 box and shares the winner's counters (2.2). A player on a shrieker sets it off: the block shrieks (shrieking true, a block tick in 90 ticks, level
*> event 3007); the tick ends the shriek and answers it: Darkness within 40 blocks and, at level 4 with can_summon, difficulty above Peaceful and the rule spawn_wardens, a warden near the
*> shrieker (2.3, 2.4). canRespond is false for a block with can_summon false, in Peaceful and with the rule off.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-SHRIEK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY KKEEP.
 COPY CBLOCKS.
 COPY BRWORLD.
 COPY P49NSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PLAYER2             BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME2               PIC X(16) VALUE "Alex".
 01 WS-NAME2-LENGTH        BINARY-LONG VALUE 4.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-SHRIEKER            BINARY-LONG.
 01 WS-SHRIEKER-OFF        BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-MODE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-CASE240             PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-WANTED              BINARY-LONG VALUE 47.
 01 WS-EXPECTED            PIC X(32).
 01 WS-RULE-NAME           PIC X(40) VALUE "spawn_wardens".
 01 WS-RULE-ROW            BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-LVL                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DARK                BINARY-LONG VALUE 32.
 01 WS-DLEVEL              BINARY-LONG.
 01 WS-DTICKS              BINARY-LONG.
 01 WS-FOUND-T             BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-WORKING             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
*>   The shrieker (can_summon true) is a floor cell under the player; a second one with can_summon false is 6 blocks to the east.
     MOVE "minecraft:sculk_shrieker" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SHRIEKER-OFF
     MOVE 2 TO WS-MODE
     MOVE "can_summon" TO WS-NAME
     MOVE "true" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-SHRIEKER-OFF WS-NAME WS-TEXT WS-SHRIEKER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-SHRIEKER
     COMPUTE WS-FX = WS-BX + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-SHRIEKER-OFF
     MOVE CB-S-BLOCK(WS-SHRIEKER + 1) TO WS-BLOCK-ID
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 0.5
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 0.5
     MOVE 1 TO PL-ON-GROUND(WS-PLAYER)
     CALL "WT-KNOWN" USING WS-PLAYER WS-K1
     MOVE "acceptance US15 44x2§2.1 The joined player has a known row (its tracker)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-K1 > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   2.1 The tracker tick: 11999 ticks since the warning: it counts to 12000, the next tick drops the level and restarts; the cooldown counts down.
     MOVE 3 TO KK-WARD-LEVEL(WS-K1)
     MOVE 11999 TO KK-WARD-TICKS(WS-K1)
     MOVE 5 TO KK-WARD-COOL(WS-K1)
     CALL "WARDEN-TRACKERS-TICK"
     MOVE "acceptance US15 44x2§2.1 Tracker tick: 11999 + 1 = 12000, level 3, cooldown 4" TO WS-CASE
     MOVE 1200034 TO WS-EXP
     COMPUTE WS-OBS = KK-WARD-TICKS(WS-K1) * 100 + KK-WARD-LEVEL(WS-K1) * 10 + KK-WARD-COOL(WS-K1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WARDEN-TRACKERS-TICK"
     MOVE "acceptance US15 44x2§2.1 The next tick: level 2, counter 0, cooldown 3" TO WS-CASE
     MOVE 23 TO WS-EXP
     COMPUTE WS-OBS = KK-WARD-LEVEL(WS-K1) * 10 + KK-WARD-COOL(WS-K1)
     IF KK-WARD-TICKS(WS-K1) NOT = 0
         MOVE -1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO KK-WARD-LEVEL(WS-K1)
     MOVE 12000 TO KK-WARD-TICKS(WS-K1)
     MOVE 0 TO KK-WARD-COOL(WS-K1)
     CALL "WARDEN-TRACKERS-TICK"
     MOVE "acceptance US15 44x2§2.1 The level never falls below 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE KK-WARD-LEVEL(WS-K1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   2.2 tryWarn: a fresh tracker gives level 1, cooldown 200, counter 0; at once again it is on cooldown (nothing).
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-TICKS(WS-K1) KK-WARD-COOL(WS-K1)
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 tryWarn of a fresh tracker: level 1, cooldown 200" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS = WS-LEVEL * 1000 + KK-WARD-COOL(WS-K1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 On cooldown tryWarn gives no level" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A warden within 48 blocks of the block: no level.
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-COOL(WS-K1)
     COMPUTE WS-WX = WS-BX + 20
     COMPUTE WS-WZ = WS-BZ + 20
     MOVE "minecraft:warden" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-WX WS-Y WS-WZ WS-WARDEN
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 A warden within the 48 box: no level" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER WS-LEVEL
*>   The shrieker does not shriek while the warden is near.
     CALL "SHRIEKER-TRY" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     MOVE 1 TO WS-MODE
     MOVE "shrieking" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 With a warden near the shrieker does not shriek" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-WARDEN

*>   Two players within 16 blocks: Alex (level 2) wins over Steve (level 0): both end with (3, 200, 0).
     CALL "TEST-JOIN" USING WS-NAME2 WS-NAME2-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-PLAYER2
     MOVE 0 TO PL-MODE(WS-PLAYER2)
     MOVE PL-DIM(WS-PLAYER) TO PL-DIM(WS-PLAYER2)
     COMPUTE PL-X(WS-PLAYER2) = WS-BX + 3.5
     MOVE PL-Y(WS-PLAYER) TO PL-Y(WS-PLAYER2)
     MOVE PL-Z(WS-PLAYER) TO PL-Z(WS-PLAYER2)
     CALL "WT-KNOWN" USING WS-PLAYER2 WS-K2
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-COOL(WS-K1) KK-WARD-TICKS(WS-K1)
     MOVE 2 TO KK-WARD-LEVEL(WS-K2)
     MOVE 0 TO KK-WARD-COOL(WS-K2)
     MOVE 77 TO KK-WARD-TICKS(WS-K2)
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 The highest level wins: 2 becomes 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44x2§2.2 Both trackers take the winner's counters (3, 200, 0)" TO WS-CASE
     MOVE 3200 TO WS-EXP
     MOVE -1 TO WS-OBS
     IF KK-WARD-LEVEL(WS-K1) = 3 AND KK-WARD-COOL(WS-K1) = 200 AND KK-WARD-TICKS(WS-K1) = 0
             AND KK-WARD-LEVEL(WS-K2) = 3 AND KK-WARD-COOL(WS-K2) = 200 AND KK-WARD-TICKS(WS-K2) = 0
         MOVE 3200 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Alex moves out of the way (spectator: no candidate, and far from the block).
     MOVE 3 TO PL-MODE(WS-PLAYER2)
     COMPUTE PL-X(WS-PLAYER2) = WS-BX + 100.5

*>   canRespond: can_summon true, not Peaceful, rule on.
     CALL "SHRIEKER-CAN-RESPOND" USING WS-SHRIEKER WS-OK
     MOVE "acceptance US15 44x2§2.3 canRespond: can_summon, Normal difficulty, rule on" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SHRIEKER-CAN-RESPOND" USING WS-SHRIEKER-OFF WS-OK
     MOVE "acceptance US15 44x2§2.3 canRespond is false with can_summon false" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO BW-DIFFICULTY
     CALL "SHRIEKER-CAN-RESPOND" USING WS-SHRIEKER WS-OK
     MOVE "acceptance US15 44x2§2.3 canRespond is false in Peaceful (SHRIEKER-CAN-RESPOND reads the world's difficulty)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO BW-DIFFICULTY
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-ROW
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
     CALL "SHRIEKER-CAN-RESPOND" USING WS-SHRIEKER WS-OK
     MOVE "acceptance US15 44x2§2.3 canRespond is false with spawn_wardens off" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE

*>   2.3 A player on the shrieker sets it off: shrieking, a block tick in 90 ticks, level event 3007, the tracker at level 1.
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-COOL(WS-K1) KK-WARD-TICKS(WS-K1)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "SHRIEKER-STEP-ON" USING WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     MOVE 1 TO WS-MODE
     MOVE "shrieking" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 Stepping on the shrieker sets shrieking" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "BT-HAS" USING WS-DIM WS-TYPE-BLOCK WS-BLOCK-ID WS-BX WS-FY WS-BZ WS-FOUND-T
     MOVE "acceptance US15 44x2§2.3 A block tick of the shrieker is scheduled" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-FOUND-T TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44x2§2.3 The tracker went to level 1 (cooldown 200)" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS = KK-WARD-LEVEL(WS-K1) * 1000 + KK-WARD-COOL(WS-K1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-LVL
     CALL "SHRIEKER-LEVEL" USING WS-DIM WS-BX WS-FY WS-BZ WS-MODE WS-LVL
     MOVE "acceptance US15 44x2§2.3 The shrieker stores the warning level 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-LVL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PN-CHECK-PREFIX" USING WS-CONN WS-WANTED
*>   While it shrieks a second step changes nothing.
     CALL "SHRIEKER-TRY" USING WS-DIM WS-BX WS-FY WS-BZ WS-PLAYER
     MOVE "acceptance US15 44x2§2.3 A shrieking shrieker ignores another step (the cooldown stays 200)" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS = KK-WARD-LEVEL(WS-K1) * 1000 + KK-WARD-COOL(WS-K1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The scheduled tick: shrieking ends, Darkness within 40 blocks, no warden at level 1.
     CALL "EFFECT-CLEAR-ALL" USING WS-PLAYER
     CALL "SHRIEKER-HOOK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     MOVE 1 TO WS-MODE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 The block tick ends the shriek" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-DARK WS-DLEVEL WS-DTICKS
     MOVE "acceptance US15 44x2§2.3 The reply applies Darkness (260 ticks) within 40 blocks" TO WS-CASE
     MOVE 260 TO WS-EXP
     MOVE WS-DTICKS TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM COUNT-WARDENS
     MOVE "acceptance US15 44x2§2.3 No warden at warning level 1" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Level 4: three earlier warnings and no cooldown: this shriek reaches 4 and the tick summons a warden within 5 blocks, standing on the floor.
     MOVE 3 TO KK-WARD-LEVEL(WS-K1)
     MOVE 0 TO KK-WARD-COOL(WS-K1)
     CALL "SHRIEKER-STEP-ON" USING WS-PLAYER
     MOVE "acceptance US15 44x2§2.3 The fourth warning is level 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     MOVE KK-WARD-LEVEL(WS-K1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     CALL "SHRIEKER-HOOK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     PERFORM COUNT-WARDENS
     MOVE "acceptance US15 44x2§2.3 At level 4 the tick summons a warden" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44x2§2.4 The warden stands on the floor within 5 blocks of the shrieker" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-WORKING > 0
         IF EN-Y(WS-WORKING) = WS-FY + 1 AND FUNCTION ABS(EN-X(WS-WORKING) - WS-BX - 0.5) <= 5
                 AND FUNCTION ABS(EN-Z(WS-WORKING) - WS-BZ - 0.5) <= 5
             MOVE 1 TO WS-OBS
         END-IF
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     IF WS-WORKING > 0
         CALL "ENTITY-REMOVE" USING WS-WORKING
     END-IF

*>   A shrieker with can_summon false (live sculk growth): it shrieks without asking the tracker, the tracker stays, nothing answers.
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-COOL(WS-K1)
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     CALL "SHRIEKER-STEP-ON" USING WS-PLAYER
     COMPUTE WS-FX = WS-BX + 6
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STATE
     MOVE 1 TO WS-MODE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 A shrieker with can_summon false shrieks too" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44x2§2.3 The tracker is not asked (level 0, no cooldown)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = KK-WARD-LEVEL(WS-K1) * 1000 + KK-WARD-COOL(WS-K1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "EFFECT-CLEAR-ALL" USING WS-PLAYER
     CALL "SHRIEKER-HOOK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STATE
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-DARK WS-DLEVEL WS-DTICKS
     MOVE "acceptance US15 44x2§2.3 Without canRespond the tick answers nothing (no Darkness)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DTICKS TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.

*> The wardens of the dimension: WS-COUNT, the last row in WS-WORKING.
 COUNT-WARDENS.
     MOVE 0 TO WS-COUNT WS-WORKING
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 IF SM-KEY(WS-M) = "warden"
                     ADD 1 TO WS-COUNT
                     MOVE WS-E TO WS-WORKING
                 END-IF
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-P49N-SHRIEK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM PN-SPAWN.

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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-CHECK-PREFIX.
*> USING connection id, wanted packet id: the Level Event 3007 (hex 00000bbf) with data 0 and global false is the first packet of that id drained from the connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AREA                PIC X(65536) BASED.
 01 WS-COPY                PIC X(512).
 01 WS-HEX                 PIC X(1024).
 01 WS-TEXT                PIC X(1024).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-WANTED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-WANTED.
     MOVE "none" TO WS-HEX
     MOVE 0 TO WS-FOUND WS-OUTCOME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             COMPUTE WS-COUNT = PK-LENGTH - PK-POS
             MOVE SPACES TO WS-COPY
             MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
             CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     MOVE SPACES TO WS-TEXT
     MOVE WS-HEX(1:8) TO WS-TEXT(1:8)
     MOVE "acceptance US15 44x2§2.3 The shriek sends level event 3007 (00000bbf)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "00000bbf" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM PN-CHECK-PREFIX.
 COPY CORETEST.
 COPY MOBSPTEST.
