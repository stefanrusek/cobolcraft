*> The wandering trader spawner and despawn (docs/protocol/19 section 23; lane 002-lane-mobsb4, T8802). The state is TRADERSP.cpy and VL-DESPAWN, VL-LLAMA-A, VL-LLAMA-B of VILSTATE.cpy.
*> Gaps: the heightmap (the ground is found by a column scan of 33 cells round the player's height), the biome tag without_wandering_trader_spawns (only the void), the llamas are not
*> leashed to the trader (a lead holds only a player here), the trader's home restriction radius 16 and wander target are recorded as the home block only, no UseItem invisibility potion
*> (the despawn is the 48000 tick delay), the delay does not stop while a player trades, the llamas do not follow the trader's death, TraderLlamaDefendWanderingTrader and the avoid goals.
*>
*>   TRADER-GROUND USING dim, x, z, y hint, found out, y out    a cell column with solid ground and 1 x 2 free cells above (the trader's size)
*>   TRADER-SPAWN USING gate draw (nextInt(10)), ok out         one spawn attempt: gate 0 passes; ok 1 also when no player is online
*>   TRADER-TICK                                                the world spawner clock (STDMOB-SPAWN-TICK): every 1200 ticks
*>   TRADER-STEP USING entity row                               the despawn delay of a trader

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADER-GROUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                 BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-BELOW                BINARY-LONG.
 01 WS-SOLID                BINARY-LONG.
 01 WS-HIT                  BINARY-LONG.
 01 WS-CX                   FLOAT-LONG.
 01 WS-CZ                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-HALF                 FLOAT-LONG VALUE 0.3.
 01 WS-HEIGHT               FLOAT-LONG VALUE 1.95.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-HINT                  BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-HINT L-FOUND L-Y.
     MOVE 0 TO L-FOUND
     COMPUTE WS-CX = L-X + 0.5
     COMPUTE WS-CZ = L-Z + 0.5
     PERFORM VARYING WS-STEP FROM 0 BY 1 UNTIL WS-STEP > 32 OR L-FOUND = 1
         COMPUTE WS-Y = L-HINT + 16 - WS-STEP
         COMPUTE WS-BELOW = WS-Y - 1
         CALL "GI-SOLID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-SOLID
         IF WS-SOLID = 1
             MOVE WS-Y TO WS-FY
             CALL "MOVE-COLLIDES-BOX" USING L-DIM WS-CX WS-FY WS-CZ WS-HALF WS-HEIGHT WS-HIT
             IF WS-HIT = 0
                 MOVE 1 TO L-FOUND
                 MOVE WS-Y TO L-Y
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TRADER-GROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADER-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-N                    BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SALT-P               BINARY-LONG VALUE 831.
 01 WS-SALT-O               BINARY-LONG VALUE 832.
 01 WS-SALT-L               BINARY-LONG VALUE 833.
 01 WS-NINETY-SIX           BINARY-LONG VALUE 96.
 01 WS-NINE                 BINARY-LONG VALUE 9.
 01 WS-R                    BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-KIND-BELL            BINARY-LONG VALUE 2.
 01 WS-RANGE                BINARY-LONG VALUE 48.
 01 WS-FOUND                BINARY-LONG.
 01 WS-TRY                  BINARY-LONG.
 01 WS-GX                   BINARY-LONG.
 01 WS-GZ                   BINARY-LONG.
 01 WS-GY                   BINARY-LONG.
 01 WS-GOT                  BINARY-LONG.
 01 WS-FULL                 PIC X(112).
 01 WS-TYPE                 BINARY-LONG.
 01 WS-LTYPE                BINARY-LONG.
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-ROW                  BINARY-LONG.
 01 WS-LROW                 BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-DIM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-GATE                  BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-GATE L-OK.
     MOVE 0 TO L-OK
*>   A random online player; none: the attempt reports success.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-PLAYERS
         IF PL-USED(WS-I) = 1
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         MOVE 1 TO L-OK
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT-P WS-N WS-K
     MOVE 0 TO WS-P
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-PLAYERS OR WS-P > 0
         IF PL-USED(WS-I) = 1
             IF WS-N = WS-K
                 MOVE WS-I TO WS-P
             END-IF
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF L-GATE NOT = 0
         GOBACK
     END-IF
*>   The centre: the nearest bell within 48 blocks of the player, else the player.
     MOVE PL-DIM(WS-P) TO WS-DIM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-P))
     COMPUTE WS-CY = FUNCTION INTEGER(PL-Y(WS-P))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-P))
     CALL "PXI-NEAREST" USING WS-DIM WS-CX WS-CY WS-CZ WS-KIND-BELL WS-RANGE WS-GX WS-GY WS-GZ WS-FOUND
     IF WS-FOUND = 1
         MOVE WS-GX TO WS-CX
         MOVE WS-GY TO WS-CY
         MOVE WS-GZ TO WS-CZ
     END-IF
     MOVE 0 TO WS-GOT
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 10 OR WS-GOT = 1
         CALL "XP-RANDOM" USING WS-SALT-O WS-NINETY-SIX WS-R
         COMPUTE WS-GX = WS-CX + WS-R - 48
         CALL "XP-RANDOM" USING WS-SALT-O WS-NINETY-SIX WS-R
         COMPUTE WS-GZ = WS-CZ + WS-R - 48
         CALL "TRADER-GROUND" USING WS-DIM WS-GX WS-GZ WS-CY WS-GOT WS-GY
     END-PERFORM
     IF WS-GOT = 0
         GOBACK
     END-IF
     MOVE "minecraft:wandering_trader" TO WS-FULL
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-GX + 0.5
     MOVE WS-GY TO WS-Y
     COMPUTE WS-Z = WS-GZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE 48000 TO VL-DESPAWN(WS-SLOT)
     MOVE 1 TO EN-HOME-SET(WS-ROW)
     MOVE WS-CX TO EN-HOME-X(WS-ROW)
     MOVE WS-CY TO EN-HOME-Y(WS-ROW)
     MOVE WS-CZ TO EN-HOME-Z(WS-ROW)
*>   Two trader llamas within 4 blocks of the trader (each at the trader's own cell when no ground is found).
     MOVE "minecraft:trader_llama" TO WS-FULL
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-LTYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-NINE TO WS-N
         CALL "XP-RANDOM" USING WS-SALT-L WS-NINE WS-R
         COMPUTE WS-CX = WS-GX + WS-R - 4
         CALL "XP-RANDOM" USING WS-SALT-L WS-NINE WS-R
         COMPUTE WS-CZ = WS-GZ + WS-R - 4
         CALL "TRADER-GROUND" USING WS-DIM WS-CX WS-CZ WS-GY WS-GOT WS-CY
         IF WS-GOT = 0
             MOVE WS-GX TO WS-CX
             MOVE WS-GZ TO WS-CZ
             MOVE WS-GY TO WS-CY
         END-IF
         COMPUTE WS-X = WS-CX + 0.5
         MOVE WS-CY TO WS-Y
         COMPUTE WS-Z = WS-CZ + 0.5
         CALL "MOB-SPAWN" USING WS-DIM WS-LTYPE WS-X WS-Y WS-Z WS-YAW WS-LROW
         MOVE 0 TO EN-MOBAGE(WS-LROW)
         IF WS-I = 1
             MOVE EN-ID(WS-LROW) TO VL-LLAMA-A(WS-SLOT)
         ELSE
             MOVE EN-ID(WS-LROW) TO VL-LLAMA-B(WS-SLOT)
         END-IF
     END-PERFORM
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM TRADER-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY TRADERSP.
 01 WS-RULE-NAME            PIC X(40) VALUE "spawn_wandering_traders".
 01 WS-RULE                 BINARY-DOUBLE.
 01 WS-NEW                  BINARY-LONG.
 01 WS-SALT-R               BINARY-LONG VALUE 841.
 01 WS-SALT-G               BINARY-LONG VALUE 842.
 01 WS-HUNDRED              BINARY-LONG VALUE 100.
 01 WS-TEN                  BINARY-LONG VALUE 10.
 01 WS-ROLL                 BINARY-LONG.
 01 WS-GATE                 BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF TS-INIT = 0
         MOVE 1 TO TS-INIT
         MOVE 24000 TO TS-DELAY
         MOVE 25 TO TS-CHANCE
     END-IF
     IF FUNCTION MOD(CW-TICKS, 1200) NOT = 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     SUBTRACT 1200 FROM TS-DELAY
     IF TS-DELAY > 0
         GOBACK
     END-IF
     MOVE 24000 TO TS-DELAY
     CALL "VIL-WANDER-CHANCE" USING TS-CHANCE WS-NEW
     MOVE WS-NEW TO TS-CHANCE
     CALL "XP-RANDOM" USING WS-SALT-R WS-HUNDRED WS-ROLL
     IF WS-ROLL <= TS-CHANCE
         CALL "XP-RANDOM" USING WS-SALT-G WS-TEN WS-GATE
         CALL "TRADER-SPAWN" USING WS-GATE WS-OK
         IF WS-OK = 1
             MOVE 25 TO TS-CHANCE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TRADER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADER-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-E                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR VL-DESPAWN(WS-SLOT) = 0
         GOBACK
     END-IF
     SUBTRACT 1 FROM VL-DESPAWN(WS-SLOT)
     IF VL-DESPAWN(WS-SLOT) = 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) > 0 AND (EN-ID(WS-E) = VL-LLAMA-A(WS-SLOT) OR EN-ID(WS-E) = VL-LLAMA-B(WS-SLOT))
                 CALL "ENTITY-REMOVE" USING WS-E
             END-IF
         END-PERFORM
         CALL "ENTITY-REMOVE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM TRADER-STEP.
