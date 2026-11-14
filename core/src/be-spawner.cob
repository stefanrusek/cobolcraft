*> The mob spawner block entity in the live world (002-lane-mobsfull-h22; docs/protocol/31-block-entities-7-spawners-trial-vaults.md section 3, 18 section 6.12,
*> 44 part 2 section 2). BE-SP of CORE-BE holds Delay, MinSpawnDelay, MaxSpawnDelay, SpawnCount, MaxNearbyEntities, RequiredPlayerRange and SpawnRange (the layout
*> of MS6-SPAWNER-NEW in mob-18-6.cob), BE-SP-ID the species of SpawnData.entity.id without "minecraft:".
*>
*> Entry points:
*>   BE-SPAWNER-SAVE USING sp (the seven values), id (X(24)), PB-BUFFER   the keys of 3.1 in write order; SpawnData only with a species
*>   BE-SPAWNER-LOAD-KEY USING sp, id, name (X(32)), tag type, PB-BUFFER  one key of the entry (the caller read its header); other keys are skipped
*>   BE-SPAWNER-TICK USING index                                          BaseSpawner.serverTick for a live mob spawner (BE-TICK-ALL)
*> Open: SpawnPotentials (and custom spawn rules, equipment) are not modelled (a loaded list is kept only by the unmodelled-key capture), the spawn-data entity is
*> a species id only, a failed crowd check does not roll a delay (only a success does), level event 2004 and the spawn animation are not sent, trial spawners.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SPAWNER-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "Delay".
    05 FILLER              PIC X(32) VALUE "MinSpawnDelay".
    05 FILLER              PIC X(32) VALUE "MaxSpawnDelay".
    05 FILLER              PIC X(32) VALUE "SpawnCount".
    05 FILLER              PIC X(32) VALUE "MaxNearbyEntities".
    05 FILLER              PIC X(32) VALUE "RequiredPlayerRange".
    05 FILLER              PIC X(32) VALUE "SpawnRange".
 01 FILLER REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-ID                  PIC X(40).
 01 WS-ID-LENGTH           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SP.
    05 L-V                 BINARY-LONG OCCURS 7 TIMES.
 01 L-ID                   PIC X(24).
 PROCEDURE DIVISION USING L-SP L-ID PB-BUFFER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE WS-NAME(WS-I) TO WN
         MOVE 0 TO WL
         INSPECT WN TALLYING WL FOR CHARACTERS BEFORE INITIAL SPACE
         MOVE L-V(WS-I) TO WS-VALUE
         CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-VALUE
     END-PERFORM
     IF L-ID NOT = SPACES
         MOVE "SpawnData" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "entity" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE SPACES TO WS-ID
         STRING "minecraft:" DELIMITED BY SIZE L-ID DELIMITED BY SPACE INTO WS-ID
         MOVE 0 TO WS-ID-LENGTH
         INSPECT WS-ID TALLYING WS-ID-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         MOVE "id" TO WN MOVE 2 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID WS-ID-LENGTH
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE-SPAWNER-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SPAWNER-LOAD-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "Delay".
    05 FILLER              PIC X(32) VALUE "MinSpawnDelay".
    05 FILLER              PIC X(32) VALUE "MaxSpawnDelay".
    05 FILLER              PIC X(32) VALUE "SpawnCount".
    05 FILLER              PIC X(32) VALUE "MaxNearbyEntities".
    05 FILLER              PIC X(32) VALUE "RequiredPlayerRange".
    05 FILLER              PIC X(32) VALUE "SpawnRange".
 01 FILLER REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WN2                    PIC X(32).
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WS-ID                  PIC X(40).
 01 WS-ID-CAPACITY         BINARY-LONG VALUE 40.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SHORT-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SP.
    05 L-V                 BINARY-LONG OCCURS 7 TIMES.
 01 L-ID                   PIC X(24).
 01 L-NAME                 PIC X(32).
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SP L-ID L-NAME L-TYPE PB-BUFFER.
     MOVE 0 TO WS-FOUND
     IF L-TYPE = 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
             IF L-NAME = WS-NAME(WS-I)
                 MOVE WS-I TO WS-FOUND
             END-IF
         END-PERFORM
     END-IF
     EVALUATE TRUE
         WHEN WS-FOUND > 0
             CALL "PB-GET-SHORT" USING PB-BUFFER L-V(WS-FOUND)
         WHEN L-NAME = "SpawnData" AND L-TYPE = 10
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
                 IF WS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF WN = "entity" AND WS-TYPE = 10
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN2
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAPACITY WL
                         IF WS-TYPE2 = 0
                             EXIT PERFORM
                         END-IF
                         IF WN2 = "id" AND WS-TYPE2 = 8
                             MOVE SPACES TO WS-ID
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-ID-CAPACITY WS-ID-LENGTH
                             MOVE SPACES TO L-ID
                             IF WS-ID-LENGTH > 10 AND WS-ID-LENGTH < 35 AND WS-ID(1:10) = "minecraft:"
                                 COMPUTE WS-SHORT-LENGTH = WS-ID-LENGTH - 10
                                 MOVE WS-ID(11:WS-SHORT-LENGTH) TO L-ID
                             END-IF
                         ELSE
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                         END-IF
                     END-PERFORM
                 ELSE
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-IF
             END-PERFORM
         WHEN OTHER
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-SPAWNER-LOAD-KEY.

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
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-NEAR
     COMPUTE WS-R2 = BE-SP-PRANGE(L-INDEX) * BE-SP-PRANGE(L-INDEX)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = BE-DIM(L-INDEX) AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-DX = PL-X(WS-P) - BE-X(L-INDEX) - 0.5
             COMPUTE WS-DY = PL-Y(WS-P) - BE-Y(L-INDEX) - 0.5
             COMPUTE WS-DZ = PL-Z(WS-P) - BE-Z(L-INDEX) - 0.5
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF BE-SP-PRANGE(L-INDEX) < 0 OR WS-D2 < WS-R2
                 MOVE 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "MS6-SPAWNER-STEP" USING WS-STATE BE-SP(L-INDEX) WS-NEAR WS-ACTION
     IF WS-ACTION = 2
         IF BE-SP-ID(L-INDEX) = SPACES
             CALL "MS6-SPAWNER-ROLL" USING WS-STATE BE-SP(L-INDEX) BE-SP-DELAY(L-INDEX)
         ELSE
             MOVE 0 TO WS-ANY
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > BE-SP-COUNT(L-INDEX)
                 CALL "MS6-SPAWNER-ATTEMPT" USING WS-STATE BE-DIM(L-INDEX) BE-SP-ID(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX)
                     BE-Z(L-INDEX) BE-SP(L-INDEX) WS-OK
                 IF WS-OK = 1
                     MOVE 1 TO WS-ANY
                 END-IF
             END-PERFORM
             IF WS-ANY = 1
                 CALL "MS6-SPAWNER-ROLL" USING WS-STATE BE-SP(L-INDEX) BE-SP-DELAY(L-INDEX)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-SPAWNER-TICK.
