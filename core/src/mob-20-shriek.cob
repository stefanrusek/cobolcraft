*> The sculk shrieker and the warden spawn tracker (docs/protocol/44-residual-mob-questions-x2 section 2, 20 section 15, 31-8 section 6; 002-lane-p49n). The tracker is the KK-WARD-*
*> fields of KKEEP.cpy of the player's known row (they are what warden_spawn_tracker saves); the shrieker's last warning level is PN-SHRIEK (P49NSTATE.cpy).
*>
*>   WT-KNOWN USING player row, known row out: the CORE-KNOWN row of the player (0 when it has none).
*>   WARDEN-TRACKERS-TICK: ServerPlayer.tick of every player: after 12000 ticks since the last warning the level falls by 1 (and the counter restarts), else the counter rises; a cooldown above
*>     0 falls by 1 (2.1).
*>   WARDEN-TRY-WARN USING dim, x, y, z (the shrieker block), player row, level out: WardenSpawnTracker.tryWarn (2.2): 0 when a warden is inside the 48 box around the block centre or any
*>     candidate (alive players that are not spectators within 16 blocks of the centre, plus the triggering player) is on cooldown; else the highest level among them goes up by 1
*>     (cooldown 200, counter 0, at most 4) and every candidate takes the winner's three counters; the new level out.
*>   SHRIEKER-LEVEL USING dim, x, y, z, mode (1 get, 2 set, 3 clear), level (in and out): the warning_level of the block entity.
*>   SHRIEKER-CAN-RESPOND USING state, ok out: can_summon true, the difficulty is not Peaceful and the rule spawn_wardens is on (2.3).
*>   SHRIEKER-TRY USING dim, x, y, z, player row: tryShriek (2.3): nothing for no player or a block that is shrieking; the level of the block goes to 0; with canRespond the tracker must warn
*>     (else the block does not shriek); then shrieking is true (flags 2), a block tick is scheduled 90 ticks on and level event 3007 goes out.
*>   SHRIEKER-RESPOND USING dim, x, y, z: tryRespond: with canRespond and a stored level above 0: at level 4 a warden is summoned (WARDEN-SUMMON); Darkness (amplifier 0, 260 ticks, flags 4
*>     as the warden's pulse) goes to every player within 40 blocks of the block centre.
*>   WARDEN-SUMMON USING dim, x, y, z, warden row out: SpawnUtil.trySpawnMob (2.4) with 20 attempts, horizontal 5, vertical 6 and the ON_TOP_OF_COLLIDER strategy (the cell above empty, the
*>     floor solid; a cell 3 high is needed for the warden's box); 0 when no attempt succeeded.
*>   SHRIEKER-HOOK USING dim, x, y, z, state: the scheduled block tick (BU-HOOK kind 7): a shrieking shrieker stops shrieking (flags 3) and responds.
*>   SHRIEKER-STEP-ON USING player row: SculkShriekerBlock.stepOn for a player on the ground (not flying, not a spectator) whose supporting block (0.500001 below the feet) is a shrieker.
*> Not here: vibrations (the game events are not delivered to listeners), the game event SHRIEK, the reply sounds, breaking a shrieking block (preRemoveSideEffects), the saved warning_level,
*> and the warden's own finalize memories beyond what MOB-SPAWN does.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-KNOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KNOWN.
     MOVE 0 TO L-KNOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KN-COUNT OR L-KNOWN > 0
         IF KN-UUID(WS-I) = PL-UUID(L-ROW)
             MOVE WS-I TO L-KNOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WT-KNOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-TRACKERS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY KKEEP.
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             CALL "WT-KNOWN" USING WS-P WS-K
             IF WS-K > 0
                 IF KK-WARD-TICKS(WS-K) >= 12000
                     IF KK-WARD-LEVEL(WS-K) > 0
                         SUBTRACT 1 FROM KK-WARD-LEVEL(WS-K)
                     END-IF
                     MOVE 0 TO KK-WARD-TICKS(WS-K)
                 ELSE
                     ADD 1 TO KK-WARD-TICKS(WS-K)
                 END-IF
                 IF KK-WARD-COOL(WS-K) > 0
                     SUBTRACT 1 FROM KK-WARD-COOL(WS-K)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-TRACKERS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-TRY-WARN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY KKEEP.
 COPY STDMOBS.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-K              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-CAND.
    05 WS-C                BINARY-LONG OCCURS 65 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-PLAYER L-LEVEL.
     MOVE 0 TO L-LEVEL WS-BLOCKED WS-N
     COMPUTE WS-CX = L-X + 0.5
     COMPUTE WS-CY = L-Y + 0.5
     COMPUTE WS-CZ = L-Z + 0.5
*>   A warden inside the box of 48 around the block centre ends it.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-BLOCKED = 1
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND EN-PLAYER(WS-E) = 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 IF SM-KEY(WS-M) = "warden" AND FUNCTION ABS(EN-X(WS-E) - WS-CX) <= 24
                         AND FUNCTION ABS(EN-Y(WS-E) - WS-CY) <= 24 AND FUNCTION ABS(EN-Z(WS-E) - WS-CZ) <= 24
                     MOVE 1 TO WS-BLOCKED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BLOCKED = 1
         GOBACK
     END-IF
*>   The candidates: alive players that are not spectators within 16 blocks, then the triggering player when he is not among them.
     MOVE 0 TO WS-HAS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-D2 = (PL-X(WS-P) - WS-CX) ** 2 + (PL-Y(WS-P) - WS-CY) ** 2 + (PL-Z(WS-P) - WS-CZ) ** 2
             IF WS-D2 < 256
                 ADD 1 TO WS-N
                 MOVE WS-P TO WS-C(WS-N)
                 IF WS-P = L-PLAYER
                     MOVE 1 TO WS-HAS
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-HAS = 0
         ADD 1 TO WS-N
         MOVE L-PLAYER TO WS-C(WS-N)
     END-IF
     MOVE 0 TO WS-BEST WS-BEST-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "WT-KNOWN" USING WS-C(WS-I) WS-K
         IF WS-K = 0
             GOBACK
         END-IF
         IF KK-WARD-COOL(WS-K) > 0
             GOBACK
         END-IF
         IF WS-BEST = 0 OR KK-WARD-LEVEL(WS-K) > KK-WARD-LEVEL(WS-BEST-K)
             MOVE WS-I TO WS-BEST
             MOVE WS-K TO WS-BEST-K
         END-IF
     END-PERFORM
     MOVE 0 TO KK-WARD-TICKS(WS-BEST-K)
     MOVE 200 TO KK-WARD-COOL(WS-BEST-K)
     IF KK-WARD-LEVEL(WS-BEST-K) < 4
         ADD 1 TO KK-WARD-LEVEL(WS-BEST-K)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "WT-KNOWN" USING WS-C(WS-I) WS-K
         MOVE KK-WARD-LEVEL(WS-BEST-K) TO KK-WARD-LEVEL(WS-K)
         MOVE KK-WARD-COOL(WS-BEST-K) TO KK-WARD-COOL(WS-K)
         MOVE KK-WARD-TICKS(WS-BEST-K) TO KK-WARD-TICKS(WS-K)
     END-PERFORM
     MOVE KK-WARD-LEVEL(WS-BEST-K) TO L-LEVEL
     GOBACK.
 END PROGRAM WARDEN-TRY-WARN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY P49NSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-MODE L-LEVEL.
     MOVE 0 TO WS-SLOT WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PN-SH-MAX
         IF PN-SH-USED(WS-I) = 1
             IF PN-SH-DIM(WS-I) = L-DIM AND PN-SH-X(WS-I) = L-X AND PN-SH-Y(WS-I) = L-Y AND PN-SH-Z(WS-I) = L-Z
                 MOVE WS-I TO WS-SLOT
             END-IF
         ELSE
             IF WS-FREE = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         END-IF
     END-PERFORM
     EVALUATE L-MODE
         WHEN 1
             MOVE 0 TO L-LEVEL
             IF WS-SLOT > 0
                 MOVE PN-SH-LEVEL(WS-SLOT) TO L-LEVEL
             END-IF
         WHEN 2
             IF WS-SLOT = 0 AND WS-FREE > 0
                 MOVE WS-FREE TO WS-SLOT
                 MOVE 1 TO PN-SH-USED(WS-SLOT)
                 MOVE L-DIM TO PN-SH-DIM(WS-SLOT)
                 MOVE L-X TO PN-SH-X(WS-SLOT)
                 MOVE L-Y TO PN-SH-Y(WS-SLOT)
                 MOVE L-Z TO PN-SH-Z(WS-SLOT)
             END-IF
             IF WS-SLOT > 0
                 MOVE L-LEVEL TO PN-SH-LEVEL(WS-SLOT)
                 IF L-LEVEL = 0
                     MOVE 0 TO PN-SH-USED(WS-SLOT)
                 END-IF
             END-IF
         WHEN OTHER
             IF WS-SLOT > 0
                 MOVE 0 TO PN-SH-USED(WS-SLOT)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SHRIEKER-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-CAN-RESPOND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawn_wardens".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-NAME                PIC X(24) VALUE "can_summon".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-OK.
     MOVE 0 TO L-OK
     CALL "BR-WORLD-READY"
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 1 AND WS-TEXT = "true" AND BW-DIFFICULTY NOT = 0 AND WS-RULE NOT = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM SHRIEKER-CAN-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-SET-SHRIEKING.
*> USING dim, x, y, z, state, value (1 true, 0 false), flags: the state of the block with shrieking set, written with those setBlock flags.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24) VALUE "shrieking".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-VALUE L-FLAGS.
     MOVE "false" TO WS-TEXT
     IF L-VALUE = 1
         MOVE "true" TO WS-TEXT
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-NEW
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW L-FLAGS WS-BUDGET WS-RESULT
     GOBACK.
 END PROGRAM SHRIEKER-SET-SHRIEKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-TRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "shrieking".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SET                 BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 90.
 01 WS-PRIO                BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3007.
 01 WS-DATA                BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-PLAYER.
     IF L-PLAYER = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 0 OR WS-TEXT = "true"
         GOBACK
     END-IF
     CALL "SHRIEKER-LEVEL" USING L-DIM L-X L-Y L-Z WS-SET WS-ZERO
     CALL "SHRIEKER-CAN-RESPOND" USING WS-STATE WS-OK
     IF WS-OK = 1
         CALL "WARDEN-TRY-WARN" USING L-DIM L-X L-Y L-Z L-PLAYER WS-LEVEL
         IF WS-LEVEL = 0
             GOBACK
         END-IF
         CALL "SHRIEKER-LEVEL" USING L-DIM L-X L-Y L-Z WS-SET WS-LEVEL
     END-IF
     CALL "SHRIEKER-SET-SHRIEKING" USING L-DIM L-X L-Y L-Z WS-STATE WS-ONE WS-TWO
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BT-SCHEDULE" USING L-DIM WS-TYPE-BLOCK WS-BLOCK L-X L-Y L-Z WS-DELAY WS-PRIO WS-RESULT
     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-DATA WS-NONE
     GOBACK.
 END PROGRAM SHRIEKER-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-SUMMON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY XORO.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:warden".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ATTEMPT             BINARY-LONG.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-HEAD2               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW WS-DONE
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-SEED = L-X * 3129871 + L-Z * 116129781 + L-Y * 7919 + CW-TICKS
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     PERFORM VARYING WS-ATTEMPT FROM 0 BY 1 UNTIL WS-ATTEMPT >= 20 OR WS-DONE = 1
         CALL "XORO-NEXT-INT" USING XR-STATE WS-ELEVEN WS-DRAW
         COMPUTE WS-DX = WS-DRAW - 5
         CALL "XORO-NEXT-INT" USING XR-STATE WS-ELEVEN WS-DRAW
         COMPUTE WS-DZ = WS-DRAW - 5
         COMPUTE WS-CX = L-X + WS-DX
         COMPUTE WS-CZ = L-Z + WS-DZ
*>       The floor search: from 6 above, 13 steps down; the cell above the cursor must have no collision and the cursor a solid block.
         COMPUTE WS-Y = L-Y + 6
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y WS-CZ WS-ABOVE
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 12 OR WS-FOUND = 1
             COMPUTE WS-CY = L-Y + 5 - WS-K
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
             IF CB-SOLID(CB-S-BLOCK(WS-ABOVE + 1) + 1) = 0 AND CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                 MOVE 1 TO WS-FOUND
             ELSE
                 MOVE WS-STATE TO WS-ABOVE
             END-IF
         END-PERFORM
         IF WS-FOUND = 1
*>           The candidate is the cell above the cursor; the warden's box (2.9 high) needs the three cells free.
             COMPUTE WS-Y = WS-CY + 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y WS-CZ WS-HEAD
             COMPUTE WS-Y = WS-CY + 2
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y WS-CZ WS-HEAD2
             COMPUTE WS-Y = WS-CY + 3
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y WS-CZ WS-STATE
             IF CB-SOLID(CB-S-BLOCK(WS-HEAD + 1) + 1) = 0 AND CB-SOLID(CB-S-BLOCK(WS-HEAD2 + 1) + 1) = 0
                     AND CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 0
                 COMPUTE WS-FX = WS-CX + 0.5
                 COMPUTE WS-FY = WS-CY + 1
                 COMPUTE WS-FZ = WS-CZ + 0.5
                 CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW L-ROW
                 IF L-ROW > 0
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-SUMMON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-RESPOND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 1.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-DARKNESS            BINARY-LONG VALUE 32.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 260.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "SHRIEKER-CAN-RESPOND" USING WS-STATE WS-OK
     CALL "SHRIEKER-LEVEL" USING L-DIM L-X L-Y L-Z WS-GET WS-LEVEL
     IF WS-OK = 0 OR WS-LEVEL = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-WARDEN
     IF WS-LEVEL >= 4
         CALL "WARDEN-SUMMON" USING L-DIM L-X L-Y L-Z WS-WARDEN
     END-IF
*>   Darkness within 40 blocks of the block centre, in both cases.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-D2 = (PL-X(WS-P) - L-X - 0.5) ** 2 + (PL-Y(WS-P) - L-Y - 0.5) ** 2 + (PL-Z(WS-P) - L-Z - 0.5) ** 2
             IF WS-D2 <= 1600
                 CALL "EFFECT-ADD" USING WS-P WS-DARKNESS WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHRIEKER-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-HOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(24) VALUE "shrieking".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     IF CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) = "minecraft:sculk_shrieker" OR "sculk_shrieker"
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1 AND WS-TEXT = "true"
             CALL "SHRIEKER-SET-SHRIEKING" USING L-DIM L-X L-Y L-Z L-STATE WS-ZERO WS-THREE
             CALL "SHRIEKER-RESPOND" USING L-DIM L-X L-Y L-Z
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHRIEKER-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHRIEKER-STEP-ON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-ROW) - 0.500001)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
     IF WS-STATE > 0
         IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "minecraft:sculk_shrieker" OR "sculk_shrieker"
             CALL "SHRIEKER-TRY" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHRIEKER-STEP-ON.
