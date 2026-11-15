*> The mob spawner block entity in the live world (002-lane-mobsfull-h22; docs/protocol/31-block-entities-7-spawners-trial-vaults.md section 3, 18 section 6.12,
*> 44 part 2 section 2). The data are those of the 31-7 spawner (be-31-7.cob, saved and loaded by BEX-SAVE and BEX-LOAD-KEY): BE-XI 1 to 7 hold Delay, MinSpawnDelay,
*> MaxSpawnDelay, SpawnCount, MaxNearbyEntities, RequiredPlayerRange and SpawnRange (the layout of MS6-SPAWNER-NEW in mob-18-6.cob), BE-XI 8 says whether the spawn
*> data has an entity and BE-XT 1 holds its id with "minecraft:".
*>
*> Entry point:
*>   BE-SPAWNER-TICK USING index    BaseSpawner.serverTick for a live mob spawner (BE-TICK-ALL)
*> Open: SpawnPotentials (and custom spawn rules, equipment) are not modelled (a loaded list is kept only by the unmodelled-key capture), the spawn-data entity is
*> a species id only, a failed crowd check does not roll a delay (only a success does), level event 2004 and the spawn animation are not sent, trial spawners.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SPAWNER-TICK.
*> USING index: the server tick of a live mob spawner (31-7 3.4, 18 section 6.12). Nothing happens unless spawner_blocks_work holds and a player who is alive and not a
*> spectator stands within RequiredPlayerRange of the block centre (a negative range counts any such player). MS6-SPAWNER-STEP then decides: wait, roll, or make
*> SpawnCount attempts (MS6-SPAWNER-ATTEMPT); a spawner without a species only rolls a delay, and a round with a success rolls one too.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260612.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawner_blocks_work".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-P                   BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-SPV.
    05 WS-SPV-DELAY        BINARY-LONG.
    05 WS-SPV-MIN          BINARY-LONG.
    05 WS-SPV-MAX          BINARY-LONG.
    05 WS-SPV-COUNT        BINARY-LONG.
    05 WS-SPV-NEARBY       BINARY-LONG.
    05 WS-SPV-PRANGE       BINARY-LONG.
    05 WS-SPV-SRANGE       BINARY-LONG.
 01 WS-SPV-TABLE REDEFINES WS-SPV.
    05 WS-SPV-V            BINARY-LONG OCCURS 7 TIMES.
 01 WS-J                   BINARY-LONG.
 01 WS-SLEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-NEAR
     COMPUTE WS-R2 = BE-XI(L-INDEX, 6) * BE-XI(L-INDEX, 6)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = BE-DIM(L-INDEX) AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-DX = PL-X(WS-P) - BE-X(L-INDEX) - 0.5
             COMPUTE WS-DY = PL-Y(WS-P) - BE-Y(L-INDEX) - 0.5
             COMPUTE WS-DZ = PL-Z(WS-P) - BE-Z(L-INDEX) - 0.5
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF BE-XI(L-INDEX, 6) < 0 OR WS-D2 < WS-R2
                 MOVE 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
*>   the species of SpawnData.entity.id without "minecraft:" (spaces when the spawn data has none)
     MOVE SPACES TO WS-SPECIES
     IF BE-XI(L-INDEX, 8) = 1 AND BE-XI(L-INDEX, 9) > 10 AND BE-XI(L-INDEX, 9) < 35 AND BE-XT(L-INDEX, 1)(1:10) = "minecraft:"
         COMPUTE WS-SLEN = BE-XI(L-INDEX, 9) - 10
         MOVE BE-XT(L-INDEX, 1)(11:WS-SLEN) TO WS-SPECIES
     END-IF
*>   the seven values of the spawner as the MS6 programs take them (BE-XI 1 to 7), written back after the step
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
         MOVE BE-XI(L-INDEX, WS-J) TO WS-SPV-V(WS-J)
     END-PERFORM
     CALL "MS6-SPAWNER-STEP" USING WS-STATE WS-SPV WS-NEAR WS-ACTION
     IF WS-ACTION = 2
         IF WS-SPECIES = SPACES
             CALL "MS6-SPAWNER-ROLL" USING WS-STATE WS-SPV WS-SPV-DELAY
         ELSE
             MOVE 0 TO WS-ANY
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-SPV-COUNT
                 CALL "MS6-SPAWNER-ATTEMPT" USING WS-STATE BE-DIM(L-INDEX) WS-SPECIES BE-X(L-INDEX) BE-Y(L-INDEX)
                     BE-Z(L-INDEX) WS-SPV WS-OK
                 IF WS-OK = 1
                     MOVE 1 TO WS-ANY
                 END-IF
             END-PERFORM
             IF WS-ANY = 1
                 CALL "MS6-SPAWNER-ROLL" USING WS-STATE WS-SPV WS-SPV-DELAY
             END-IF
         END-IF
     END-IF
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
         MOVE WS-SPV-V(WS-J) TO BE-XI(L-INDEX, WS-J)
     END-PERFORM
     GOBACK.
 END PROGRAM BE-SPAWNER-TICK.
