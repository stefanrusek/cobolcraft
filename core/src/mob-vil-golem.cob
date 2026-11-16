*> Iron golem summoning by villagers (docs/protocol/19 section 22.10; lane 002-lane-mobsb4, T8801). The rule is VIL-GOLEM-WANTS (mob-19-22.cob); the state is VL-LAST-SLEPT and
*> VL-GOLEM-UNTIL of VILSTATE.cpy. The golem is a plain iron golem (no player-created flag). Gaps: the golem sensor's 200-tick rescan that sets golem_detected_recently whenever a golem is
*> near is not modelled (the memory is set only by a summon), the downward search depth of the placement (the document gives only the start 6 blocks above) is 12 cells, the full list
*> of rejected standing blocks is in the strategy method (the 12 listed families are used), the spawn-rule and world border checks, the ambient sound, the panic state of a villager is
*> read as EN-FLEE (no villager hurt/hostile sensor yet).
*>
*>   VL-GOLEM-SPOT USING dim, x, y, z (feet cell), ok out       a golem may stand there: a solid block below that is not on the rejected list, free body space
*>   VL-GOLEM-CHECK USING entity row, minimum, spawned out      spawnGolemIfNeeded
*>   VL-GOLEM-STEP USING entity row                             the panic call: every 100 ticks a panicking villager asks with minimum 3

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOLEM-SPOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SOLID                BINARY-LONG.
 01 WS-BELOW                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-LEN                  BINARY-LONG.
 01 WS-HIT                  BINARY-LONG.
 01 WS-CX                   FLOAT-LONG.
 01 WS-CZ                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-HALF                 FLOAT-LONG VALUE 0.7.
 01 WS-HEIGHT               FLOAT-LONG VALUE 2.7.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-BELOW = L-Y - 1
     CALL "GI-SOLID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-SOLID
     IF WS-SOLID = 0
         GOBACK
     END-IF
     CALL "PXI-KEY-AT" USING L-DIM L-X WS-BELOW L-Z WS-KEY
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     EVALUATE TRUE
         WHEN WS-KEY = "cobweb" OR "cactus" OR "glass_pane" OR "conduit" OR "ice"
                 OR "tnt" OR "glowstone" OR "beacon" OR "sea_lantern" OR "frosted_ice"
                 OR "tinted_glass" OR "glass"
             GOBACK
         WHEN WS-LEN > 7 AND WS-KEY(WS-LEN - 6:7) = "_leaves"
             GOBACK
         WHEN WS-LEN > 14 AND WS-KEY(WS-LEN - 13:14) = "_stained_glass"
             GOBACK
         WHEN WS-LEN > 19 AND WS-KEY(WS-LEN - 18:19) = "_stained_glass_pane"
             GOBACK
     END-EVALUATE
     COMPUTE WS-CX = L-X + 0.5
     COMPUTE WS-CZ = L-Z + 0.5
     MOVE L-Y TO WS-FY
     CALL "MOVE-COLLIDES-BOX" USING L-DIM WS-CX WS-FY WS-CZ WS-HALF WS-HEIGHT WS-HIT
     IF WS-HIT = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM VL-GOLEM-SPOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOLEM-WANTS-ROW.
*> USING slot, wants out: wantsToSpawnGolem(time): slept within 24000 ticks and no golem detected.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLEPT                BINARY-LONG.
 01 WS-DETECTED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-YES.
     MOVE VL-LAST-SLEPT(L-SLOT) TO WS-SLEPT
     IF WS-SLEPT = 0
         MOVE -1 TO WS-SLEPT
     END-IF
     MOVE 0 TO WS-DETECTED
     IF VL-GOLEM-UNTIL(L-SLOT) > CW-TICKS
         MOVE 1 TO WS-DETECTED
     END-IF
     CALL "VIL-GOLEM-WANTS" USING CW-TICKS WS-SLEPT WS-DETECTED L-YES
     GOBACK.
 END PROGRAM VL-GOLEM-WANTS-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOLEM-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-YES                  BINARY-LONG.
 01 WS-KEY                  PIC X(24).
 01 WS-E                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-LIST                 BINARY-LONG OCCURS 5 TIMES.
 01 WS-ESLOT                BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-TRY                  BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 811.
 01 WS-SEVENTEEN            BINARY-LONG VALUE 17.
 01 WS-R                    BINARY-LONG.
 01 WS-BX                   BINARY-LONG.
 01 WS-BY                   BINARY-LONG.
 01 WS-BZ                   BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-STEP                 BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-FULL                 PIC X(112).
 01 WS-TYPE                 BINARY-LONG.
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-GOLEM                BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-I                    BINARY-LONG.
 01 WS-ISLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-MIN                   BINARY-LONG.
 01 L-SPAWNED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MIN L-SPAWNED.
     MOVE 0 TO L-SPAWNED
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     CALL "VL-GOLEM-WANTS-ROW" USING WS-SLOT WS-YES
     IF WS-YES = 0
         GOBACK
     END-IF
*>   Step 1: the villagers within 10 blocks that also want one, at most 5.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-N >= 5
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
             IF WS-KEY = "villager"
                 COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                 COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                 IF FUNCTION ABS(WS-DX) <= 10 AND FUNCTION ABS(WS-DY) <= 10 AND FUNCTION ABS(WS-DZ) <= 10
                     CALL "VL-FIND" USING EN-ID(WS-E) WS-NO WS-ESLOT
                     IF WS-ESLOT > 0
                         CALL "VL-GOLEM-WANTS-ROW" USING WS-ESLOT WS-YES
                         IF WS-YES = 1
                             ADD 1 TO WS-N
                             MOVE WS-E TO WS-LIST(WS-N)
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N < L-MIN
         GOBACK
     END-IF
*>   Step 3: up to 10 attempts at an offset of -8 to 8 in x and z, searching down from 6 blocks above.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 10 OR WS-DONE = 1
         CALL "XP-RANDOM" USING WS-SALT WS-SEVENTEEN WS-R
         COMPUTE WS-CX = WS-BX + WS-R - 8
         CALL "XP-RANDOM" USING WS-SALT WS-SEVENTEEN WS-R
         COMPUTE WS-CZ = WS-BZ + WS-R - 8
         PERFORM VARYING WS-STEP FROM 0 BY 1 UNTIL WS-STEP > 12 OR WS-DONE = 1
             COMPUTE WS-CY = WS-BY + 6 - WS-STEP
             CALL "VL-GOLEM-SPOT" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-OK
             IF WS-OK = 1
                 MOVE 1 TO WS-DONE
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-DONE = 0
         GOBACK
     END-IF
     MOVE "minecraft:iron_golem" TO WS-FULL
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-CX + 0.5
     MOVE WS-CY TO WS-Y
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-GOLEM
     MOVE 1 TO L-SPAWNED
*>   Step 4: every asker remembers a golem for 599 ticks.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "VL-FIND" USING EN-ID(WS-LIST(WS-I)) WS-NO WS-ISLOT
         COMPUTE VL-GOLEM-UNTIL(WS-ISLOT) = CW-TICKS + 599
     END-PERFORM
     GOBACK.
 END PROGRAM VL-GOLEM-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOLEM-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MIN                  BINARY-LONG VALUE 3.
 01 WS-SPAWNED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-FLEE(L-ROW) > 0 AND FUNCTION MOD(CW-TICKS, 100) = 0
         CALL "VL-GOLEM-CHECK" USING L-ROW WS-MIN WS-SPAWNED
     END-IF
     GOBACK.
 END PROGRAM VL-GOLEM-STEP.
