*> Test of 31-7 section 3, Mob spawner (core/src/be-31-7.cob; T0959): saved keys and their order, shorts, the spawn data and potentials, the weighted pick, the update tag, the block event, edits and the engine facts.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-7-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-FV                  FLOAT-SHORT.
 01 WS-IA.
    05 WS-IAV              BINARY-LONG OCCURS 8 TIMES.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-Q                 BINARY-LONG.
 01 WS-R                 BINARY-LONG.
 01 WS-S                 BINARY-LONG.
 01 WS-U                 BINARY-LONG.
 01 WS-V                 BINARY-LONG.
 01 WS-W                 BINARY-LONG.
 01 WS-EV                BINARY-LONG.
 01 WS-O1                 BINARY-LONG.
 01 WS-O2                 BINARY-LONG.
 01 WS-O3                 BINARY-LONG.
 01 WS-O4                 BINARY-LONG.
 01 WS-O5                 BINARY-LONG.
 01 WS-O6                 BINARY-LONG.
 01 WS-O7                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-FG                FLOAT-LONG.
 01 WS-FH                FLOAT-LONG.
 01 WS-FS1                FLOAT-SHORT.
 01 WS-FS2                FLOAT-SHORT.
 01 WS-FS3                FLOAT-SHORT.
 01 WS-FS4                FLOAT-SHORT.
 01 WS-N24                PIC X(24).
 01 WS-N48                PIC X(48).
 01 WS-T64                PIC X(64).
 01 WS-T256               PIC X(256).
 01 WS-T2                 PIC X(64).
 01 WS-TAB.
    05 WS-TV              BINARY-LONG OCCURS 64 TIMES.
 01 WS-LONG1              BINARY-DOUBLE.
 01 WS-LONG2              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-7§3 Mob spawner: fresh spawner (3.1): the seven numbers as shorts with the defaults 20, 200, 800, 4, 6, 16, 4 and the always written SpawnPotentials with one entry of weight 1 holding the empty spawn data" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: spawn data (3.1, example 7.3): the id is normalised to minecraft:zombie, SpawnData is written when present, and the default SpawnPotentials is one entry of the current spawn data with weight 1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "zombie" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{id:minecraft:zombie}},SpawnPotentials:[{data:{entity:{id:minecraft" &
         ":zombie}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: custom spawn rules (3.1): block_light_limit and sky_light_limit as inclusive ranges are kept; a limit outside 0 to 15 or an invalid id drops the rules or the id" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:skeleton" TO WS-SV
     MOVE 18 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "custom_spawn_rules" TO WS-NM
     MOVE 18 TO WS-NML
     PERFORM NB-C
     MOVE "block_light_limit" TO WS-NM
     MOVE 17 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 7 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "sky_light_limit" TO WS-NM
     MOVE 15 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 15 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "Bad Id" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "custom_spawn_rules" TO WS-NM
     MOVE 18 TO WS-NML
     PERFORM NB-C
     MOVE "block_light_limit" TO WS-NM
     MOVE 17 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 16 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "sky_light_limit" TO WS-NM
     MOVE 15 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 15 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{id:minecraft:skeleton},custom_spawn_rules:{block_light_limit:{min_" &
         "inclusive:2,max_inclusive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{" &
         "data:{entity:{id:minecraft:skeleton},custom_spawn_rules:{block_light_limit:{min_inclusive:2,max_incl" &
         "usive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},weight:1}]} {Delay:20,MinSpawnDelay:20" &
         "0,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{" &
         "entity:{}},SpawnPotentials:[{data:{entity:{}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: potentials (3.1): explicit entries {data, weight} are kept in order; an entry without weight or with a negative weight fails the list, which then falls back to the default one entry list" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:zombie" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "weight" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:spider" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "weight" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 15) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:pig" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:zombie" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 15) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:zombie" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "weight" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE -1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnPotentials:[{data:{entity:{id:minecraft:zombie}},weight:3},{data:{entity:{id:min" &
         "ecraft:spider}},weight:5}]} 2 {Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEn" &
         "tities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{id:minecraft:pig}},SpawnPotentials:[" &
         "{data:{entity:{id:minecraft:pig}},weight:1}]} 0 {Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnC" &
         "ount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},we" &
         "ight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: numbers (3.1): MinSpawnDelay, MaxSpawnDelay, SpawnCount, MaxNearbyEntities, RequiredPlayerRange and SpawnRange load from shorts or ints, Delay only from a short; the values save as shorts, a" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Delay" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     MOVE "MinSpawnDelay" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 500 TO WS-NV
     PERFORM NB-I
     MOVE 3 TO WS-NV
     MOVE "SpawnCount" TO WS-NM
     MOVE 10 TO WS-NML
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WS-NM WS-NML WS-NV
     MOVE "MaxSpawnDelay" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 40000 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:500,MaxSpawnDelay:-25536,SpawnCount:3,MaxNearbyEntities:6,RequiredPlayerRang" &
         "e:16,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: update tag (3.2): the custom form with SpawnPotentials removed, the client keeps only the current SpawnData" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:zombie" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{id:minecraft:zombie}}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: block event (3.2): id 1 is handled; on the client it sets the delay to MinSpawnDelay, on the server it has no effect; another id is not handled (side, event id in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 300 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-SPAWNER-EVENT" USING WS-IDX WS-B WS-A WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 300 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-SPAWNER-EVENT" USING WS-IDX WS-B WS-A WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 300 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-SPAWNER-EVENT" USING WS-IDX WS-B WS-A WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 300 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE7-SPAWNER-EVENT" USING WS-IDX WS-B WS-A WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 20 1 300 0 20 0 20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: weighted pick (3.1): the total weight, then one draw below the total walks the entries in order subtracting each weight; an empty list or a zero total gives none (weights, count, draw in;" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-TV(1)
     MOVE 2 TO WS-TV(2)
     MOVE 3 TO WS-TV(3)
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 2 TO WS-TV(2)
     MOVE 3 TO WS-TV(3)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 2 TO WS-TV(2)
     MOVE 3 TO WS-TV(3)
     MOVE 3 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 2 TO WS-TV(2)
     MOVE 3 TO WS-TV(3)
     MOVE 3 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 2 TO WS-TV(2)
     MOVE 3 TO WS-TV(3)
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-TV(1)
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-TV(1)
     MOVE 0 TO WS-TV(2)
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-TV(1)
     MOVE 4 TO WS-TV(2)
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-WEIGHT-TOTAL" USING WS-TAB WS-A WS-C
     CALL "BE7-WEIGHT-PICK" USING WS-TAB WS-A WS-B WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "6 1 6 2 6 2 6 3 6 3 5 1 0 0 0 0 4 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: nearby player (3.4 item 1): a living non-spectator player within the range (squared distance below range squared) or any such player for a negative range (distance squared, range in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 9 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 256 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 257 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE -1 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-NEARBY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: custom spawn rules (3.4 item 2): block light and sky light inside their inclusive limits, and a mob category that is not friendly fails on Peaceful (block light, sky light, friendly, peaceful" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 1 TO WS-A
     MOVE 10 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 8 TO WS-A
     MOVE 10 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 1 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 16 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 10)
     MOVE 7 TO BE-XI(WS-IDX, 11)
     MOVE 0 TO BE-XI(WS-IDX, 12)
     MOVE 15 TO BE-XI(WS-IDX, 13)
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE7-CUSTOM-RULES" USING WS-IDX WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 0 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: delay (7.2): MinSpawnDelay + nextInt(Max - Min) (200 to 799 for 200 and 800), exactly the minimum when the maximum is not above it (min, max, draw in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 200 TO WS-A
     MOVE 800 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DELAY" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 200 TO WS-A
     MOVE 800 TO WS-B
     MOVE 599 TO WS-C
     CALL "BE7-DELAY" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 500 TO WS-A
     MOVE 300 TO WS-B
     MOVE 77 TO WS-C
     CALL "BE7-DELAY" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 500 TO WS-A
     MOVE 500 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DELAY" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DELAY" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "200 799 500 500 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: position draws (7.1): spawner at (10, 64, -3), range 4, draws 0.75, 0.25, 2, 0.10, 0.60 give (12.5, 65, -4.5) and the crowd box (6, 60, -7) to (15, 69, 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE -3 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     COMPUTE WS-FA = 0.75
     COMPUTE WS-FB = 0.25
     COMPUTE WS-FC = 0.10
     COMPUTE WS-FD = 0.60
     MOVE 2 TO WS-A
     CALL "BE7-SPAWN-POS" USING WS-IDX WS-FA WS-FB WS-A WS-FC WS-FD WS-FE WS-FF WS-FG WS-TAB
     COMPUTE WS-SHOW ROUNDED = (WS-FE) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FF) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FG) * 1000000
     PERFORM ADD-N
     MOVE WS-TV(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "12500000 65000000 -4500000 6 60 -7 15 69 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: breaking (3.5): a broken spawner pays 15 + nextInt(15) + nextInt(15) experience, 15 to 43 (the two draws in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-BREAK-XP" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     MOVE 14 TO WS-B
     CALL "BE7-BREAK-XP" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-BREAK-XP" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 14 TO WS-B
     CALL "BE7-BREAK-XP" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "15 43 29 29" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: setEntityId (3.3): only the id of the current spawn data changes, rules and potentials stay; with no spawn data one is created; the id is normalised" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:zombie" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "custom_spawn_rules" TO WS-NM
     MOVE 18 TO WS-NML
     PERFORM NB-C
     MOVE "block_light_limit" TO WS-NM
     MOVE 17 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 7 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "sky_light_limit" TO WS-NM
     MOVE 15 TO WS-NML
     PERFORM NB-C
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 15 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:pig" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "weight" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE SPACES TO WS-T64
     MOVE "minecraft:cow" TO WS-T64
     MOVE 13 TO WS-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-IDX WS-T64 WS-LEN
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "sheep" TO WS-T64
     MOVE 5 TO WS-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-IDX WS-T64 WS-LEN
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{id:minecraft:cow},custom_spawn_rules:{block_light_limit:{min_inclu" &
         "sive:2,max_inclusive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{data:" &
         "{entity:{id:minecraft:pig}},weight:2}]} {Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,M" &
         "axNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{id:minecraft:sheep}},Spawn" &
         "Potentials:[{data:{entity:{id:minecraft:sheep}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: unknown keys (3.1): keys the spawn data does not know are skipped, an entity key other than id is not kept, a limit pair keeps its other value; a potentials list of the wrong element type or an" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "Pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "zombie" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "custom_spawn_rules" TO WS-NM
     MOVE 18 TO WS-NML
     PERFORM NB-C
     MOVE "foo" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "block_light_limit" TO WS-NM
     MOVE 17 TO WS-NML
     PERFORM NB-C
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "min_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "max_inclusive" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 3 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnPotentials" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "entity" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:pig" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "weight" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     MOVE "extra" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{id:minecraft:zombie},custom_spawn_rules:{block_light_limit:{min_in" &
         "clusive:1,max_inclusive:5},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{da" &
         "ta:{entity:{id:minecraft:zombie},custom_spawn_rules:{block_light_limit:{min_inclusive:1,max_inclusiv" &
         "e:5},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},weight:1}]} {Delay:20,MinSpawnDelay:200,Ma" &
         "xSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnPotentials" &
         ":[{data:{entity:{id:minecraft:pig}},weight:2}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§3 Mob spawner: setEntityId (3.3): an id that is no identifier leaves the spawn data with an empty entity" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 9 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "Bad Id" TO WS-T64
     MOVE 6 TO WS-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-IDX WS-T64 WS-LEN
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:1" &
         "6,SpawnRange:4,SpawnData:{entity:{}},SpawnPotentials:[{data:{entity:{}},weight:1}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-IA.
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-NM WS-NML WS-LC WS-IA
     .
 NB-FLOAT.
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-NM WS-NML WS-FV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-7-3.

 COPY CORETEST.
