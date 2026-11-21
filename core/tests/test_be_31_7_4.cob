*> Test of 31-7 section 4, Trial spawner (core/src/be-31-7.cob; T0961): saved keys, the apply-with-defaults and all-or-nothing rules, the update tag, the derived totals, tracking, detection and ejection facts.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-7-4.
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
     MOVE "acceptance US12 31-7§4 Trial spawner: fresh trial spawner (4.1): empty player and mob lists, times 0, total 0, and the default cooldown length 36000 and range 14 (no config references)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0," &
         "target_cooldown_length:36000,required_player_range:14}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: round trip (4.1): state data keys then configuration keys in order; the UUID sets are lists of int arrays of 4" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "registered_players" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE 11 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 4 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE "current_mobs" TO WS-NM
     MOVE 12 TO WS-NML
     MOVE 11 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 6 TO WS-IAV(2)
     MOVE 7 TO WS-IAV(3)
     MOVE 8 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 9 TO WS-IAV(1)
     MOVE 10 TO WS-IAV(2)
     MOVE 11 TO WS-IAV(3)
     MOVE 12 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE "cooldown_ends_at" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 1234 TO WS-LV
     PERFORM NB-LONG
     MOVE "next_mob_spawns_at" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE 99 TO WS-LV
     PERFORM NB-LONG
     MOVE "total_mobs_spawned" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     MOVE "spawn_data" TO WS-NM
     MOVE 10 TO WS-NML
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
     MOVE "ejecting_loot_table" TO WS-NM
     MOVE 19 TO WS-NML
     MOVE "minecraft:spawners/trial_chamber/key" TO WS-SV
     MOVE 36 TO WS-SVL
     PERFORM NB-S
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "minecraft:trial_chamber/melee/zombie/normal" TO WS-SV
     MOVE 43 TO WS-SVL
     PERFORM NB-S
     MOVE "ominous_config" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE "minecraft:trial_chamber/melee/zombie/ominous" TO WS-SV
     MOVE 44 TO WS-SVL
     PERFORM NB-S
     MOVE "target_cooldown_length" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE 100 TO WS-NV
     PERFORM NB-I
     MOVE "required_player_range" TO WS-NM
     MOVE 21 TO WS-NML
     MOVE 20 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{registered_players:[I[1,2,3,4]],current_mobs:[I[5,6,7,8],I[9,10,11,12]],cooldown_ends_at:1234,next_" &
         "mob_spawns_at:99,total_mobs_spawned:3,spawn_data:{entity:{id:minecraft:zombie}},ejecting_loot_table:" &
         "minecraft:spawners/trial_chamber/key,normal_config:minecraft:trial_chamber/melee/zombie/normal,omino" &
         "us_config:minecraft:trial_chamber/melee/zombie/ominous,target_cooldown_length:100,required_player_ra" &
         "nge:20} 1 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: apply with defaults (4.1, validation 7): a tag with only next_mob_spawns_at empties the sets and resets every other field; the full configuration falls back to the defaults" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "next_mob_spawns_at" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE 7 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:7,total_mobs_spawned:0," &
         "target_cooldown_length:36000,required_player_range:14}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: lenient state keys (4.1): a total below 0 or a key of the wrong tag type takes the default" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "total_mobs_spawned" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE -4 TO WS-NV
     PERFORM NB-I
     MOVE "cooldown_ends_at" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0," &
         "target_cooldown_length:36000,required_player_range:14}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: all-or-nothing configuration (4.1, validation 7): a present key that is out of range (range 200, range 0, a negative cooldown) or undecodable makes the whole configuration the built-in" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "a:b" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "target_cooldown_length" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE 50 TO WS-NV
     PERFORM NB-I
     MOVE "required_player_range" TO WS-NM
     MOVE 21 TO WS-NML
     MOVE 200 TO WS-NV
     PERFORM NB-I
     MOVE "ominous_config" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE "a:c" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "a:b" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "required_player_range" TO WS-NM
     MOVE 21 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "a:b" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "target_cooldown_length" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "target_cooldown_length" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE -1 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "a:b" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "target_cooldown_length" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE 9 TO WS-NV
     PERFORM NB-I
     MOVE "required_player_range" TO WS-NM
     MOVE 21 TO WS-NML
     MOVE 128 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0," &
         "target_cooldown_length:36000,required_player_range:14} {registered_players:[],current_mobs:[],cooldo" &
         "wn_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,target_cooldown_length:36000,required_player_" &
         "range:14} {registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_" &
         "spawned:0,target_cooldown_length:36000,required_player_range:14} {registered_players:[],current_mobs" &
         ":[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,target_cooldown_length:36000,requir" &
         "ed_player_range:14} {registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,t" &
         "otal_mobs_spawned:0,normal_config:a:b,target_cooldown_length:9,required_player_range:128}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: update tag (4.5, validation 8): next_mob_spawns_at only in state active (state 2 of the six, held in BE-STATUS from the block), spawn_data when present, nothing else" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-STATUS(WS-IDX)
     MOVE 5 TO BE-TIME2(WS-IDX)
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE "minecraft:zombie" TO BE-XT(WS-IDX, 1)
     MOVE 16 TO BE-XI(WS-IDX, 5)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-STATUS(WS-IDX)
     MOVE 5 TO BE-TIME2(WS-IDX)
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE "minecraft:zombie" TO BE-XT(WS-IDX, 1)
     MOVE 16 TO BE-XI(WS-IDX, 5)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-STATUS(WS-IDX)
     MOVE 5 TO BE-TIME2(WS-IDX)
     MOVE 0 TO BE-XI(WS-IDX, 4)
     MOVE "minecraft:zombie" TO BE-XT(WS-IDX, 1)
     MOVE 16 TO BE-XI(WS-IDX, 5)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-STATUS(WS-IDX)
     MOVE 5 TO BE-TIME2(WS-IDX)
     MOVE 0 TO BE-XI(WS-IDX, 4)
     MOVE "minecraft:zombie" TO BE-XT(WS-IDX, 1)
     MOVE 16 TO BE-XI(WS-IDX, 5)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "{next_mob_spawns_at:5,spawn_data:{entity:{id:minecraft:zombie}}} {spawn_data:{entity:{id:minecraft:z" &
         "ombie}}} {next_mob_spawns_at:5} {}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: derived totals (4.2, example 7.4): targetTotalMobs = floor(total + per player * extra) and targetSimultaneousMobs likewise (default 6 and 2, breeze normal 2 and 1, breeze ominous 4 and 2;" TO TL-CASE
     PERFORM BEGIN-CASE
     COMPUTE WS-FS1 = 6.0
     COMPUTE WS-FS2 = 2.0
     COMPUTE WS-FS3 = 2.0
     COMPUTE WS-FS4 = 1.0
     MOVE 0 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 6.0
     COMPUTE WS-FS2 = 2.0
     COMPUTE WS-FS3 = 2.0
     COMPUTE WS-FS4 = 1.0
     MOVE 2 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 2.0
     COMPUTE WS-FS2 = 1.0
     COMPUTE WS-FS3 = 1.0
     COMPUTE WS-FS4 = 0.5
     MOVE 0 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 2.0
     COMPUTE WS-FS2 = 1.0
     COMPUTE WS-FS3 = 1.0
     COMPUTE WS-FS4 = 0.5
     MOVE 1 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 2.0
     COMPUTE WS-FS2 = 1.0
     COMPUTE WS-FS3 = 1.0
     COMPUTE WS-FS4 = 0.5
     MOVE 2 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 4.0
     COMPUTE WS-FS2 = 0.0
     COMPUTE WS-FS3 = 2.0
     COMPUTE WS-FS4 = 0.5
     MOVE 2 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 4.0
     COMPUTE WS-FS2 = 0.0
     COMPUTE WS-FS3 = 2.0
     COMPUTE WS-FS4 = 0.5
     MOVE 0 TO WS-A
     CALL "BE7-TRIAL-TOTALS" USING WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "6 2 10 4 2 1 3 1 4 2 4 3 4 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: default configuration (4.2): spawn_range 4, total 6.0, simultaneous 2.0, 2.0 and 1.0 per extra player, 40 ticks between spawns, the item spawner constant 160 and the loot table keys" TO TL-CASE
     PERFORM BEGIN-CASE
     CALL "BE7-TRIAL-DEFAULT" USING WS-A WS-FS1 WS-FS2 WS-FS3 WS-FS4 WS-B WS-C
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-FS1 TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-FS2 TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-FS3 TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-FS4 TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "4 6 2 2 1 40 160" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: untracked rule (4.3 item 2): a mob that is missing, not alive, in another dimension or farther than squared distance 2209 (strictly) is removed (found, alive, same dimension, squared distance" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 100 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 2209 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 2210 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 5 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 5 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 5 TO WS-E
     CALL "BE7-UNTRACKED" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 1 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: detection throttle (4.3 item 6): BlockPos.asLong (x 26 bits at 38, z 26 bits at 12, y 12 bits) plus the game time modulo 20 must be 0 (shown as the packed value modulo 1000000007, its upper" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 70 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-LONG2
     CALL "BE7-PACK-POS" USING WS-A WS-B WS-C WS-LONG1
     CALL "BE7-DETECT-THROTTLE" USING WS-LONG1 WS-LONG2 WS-E
     MOVE FUNCTION MOD(WS-LONG1, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE FUNCTION INTEGER(WS-LONG1 / 4294967296) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 20 TO WS-LONG2
     CALL "BE7-PACK-POS" USING WS-A WS-B WS-C WS-LONG1
     CALL "BE7-DETECT-THROTTLE" USING WS-LONG1 WS-LONG2 WS-E
     MOVE FUNCTION MOD(WS-LONG1, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE FUNCTION INTEGER(WS-LONG1 / 4294967296) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-A
     MOVE 70 TO WS-B
     MOVE 9 TO WS-C
     MOVE 3 TO WS-LONG2
     CALL "BE7-PACK-POS" USING WS-A WS-B WS-C WS-LONG1
     CALL "BE7-DETECT-THROTTLE" USING WS-LONG1 WS-LONG2 WS-E
     MOVE FUNCTION MOD(WS-LONG1, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE FUNCTION INTEGER(WS-LONG1 / 4294967296) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE -5 TO WS-A
     MOVE 64 TO WS-B
     MOVE 7 TO WS-C
     MOVE 13 TO WS-LONG2
     CALL "BE7-PACK-POS" USING WS-A WS-B WS-C WS-LONG1
     CALL "BE7-DETECT-THROTTLE" USING WS-LONG1 WS-LONG2 WS-E
     MOVE FUNCTION MOD(WS-LONG1, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE FUNCTION INTEGER(WS-LONG1 / 4294967296) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE -3 TO WS-B
     MOVE -8 TO WS-C
     MOVE 77 TO WS-LONG2
     CALL "BE7-PACK-POS" USING WS-A WS-B WS-C WS-LONG1
     CALL "BE7-DETECT-THROTTLE" USING WS-LONG1 WS-LONG2 WS-E
     MOVE FUNCTION MOD(WS-LONG1, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE FUNCTION INTEGER(WS-LONG1 / 4294967296) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "70 0 0 0 0 1 779087138 640 0 610503641 -320 0 668378335 6463 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: player filter (4.3 item 7, example 7.7): strictly inside the range squared (181 of 196 yes, 196 no), not a spectator, not creative unless the detector includes creative players, and a clear" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 181 TO WS-A
     MOVE 14 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 196 TO WS-A
     MOVE 14 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 14 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 14 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 14 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     MOVE 1 TO WS-H
     CALL "BE7-PLAYER-DETECT" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 1 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: detection plan (4.3 item 6): an ominous spawner in cooldown does not detect; a non-ominous one becomes ominous when a listed player has the trial_omen effect; in cooldown without that it" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     MOVE 0 TO WS-E
     MOVE 3 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     CALL "BE7-DETECT-PLAN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 0 1 0 1 0 0 1 1 0 1 0 1 0 0 0 1 0 0 0 2 0 0 0 1 0 0 0 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: players added (4.3 item 6): next_mob_spawns_at becomes max(game time + 40, itself), and level event 3019 (ominous) or 3013 follows unless the omen flag is set; nothing when nobody was added" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE 100 TO WS-LONG1
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DETECT-ADDED" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 500 TO BE-TIME2(WS-IDX)
     MOVE 100 TO WS-LONG1
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE7-DETECT-ADDED" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 120 TO BE-TIME2(WS-IDX)
     MOVE 100 TO WS-LONG1
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DETECT-ADDED" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 50 TO BE-TIME2(WS-IDX)
     MOVE 100 TO WS-LONG1
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-DETECT-ADDED" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "3013 140 3019 500 0 140 0 50" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: ejection (4.3 item 10, example 7.6): a reward is ejected once per detected player on a tick with (game time - (cooldown_ends_at - target cooldown)) mod 30 = 0 (game time, cooldown end," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 60 TO WS-LONG1
     MOVE 36060 TO WS-LONG2
     MOVE 36000 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-EJECT-TICK" USING WS-LONG1 WS-LONG2 WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 61 TO WS-LONG1
     MOVE 36060 TO WS-LONG2
     MOVE 36000 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-EJECT-TICK" USING WS-LONG1 WS-LONG2 WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 90 TO WS-LONG1
     MOVE 36060 TO WS-LONG2
     MOVE 36000 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-EJECT-TICK" USING WS-LONG1 WS-LONG2 WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 120 TO WS-LONG1
     MOVE 36060 TO WS-LONG2
     MOVE 36000 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-EJECT-TICK" USING WS-LONG1 WS-LONG2 WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 30 TO WS-LONG1
     MOVE 36000 TO WS-LONG2
     MOVE 36000 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-EJECT-TICK" USING WS-LONG1 WS-LONG2 WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: ejection event (4.3 item 10): level event 3014 only when the roll produced at least one stack" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     CALL "BE7-EJECT-EVENT" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     CALL "BE7-EJECT-EVENT" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     CALL "BE7-EJECT-EVENT" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 3014 3014" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: canSpawnInLevel (4.3 item 5): false without spawner_blocks_work, true with the override, else not on Peaceful and only when spawn_mobs holds (work rule, override, peaceful, spawn_mobs in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE7-CAN-SPAWN" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CAN-SPAWN" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE7-CAN-SPAWN" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE7-CAN-SPAWN" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE7-CAN-SPAWN" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: hasMobToSpawn (4.3 item 9): the stored entity compound has an id, or the potentials list is not empty (spawn data set, id length, potentials count in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 16 TO BE-XI(WS-IDX, 5)
     MOVE 0 TO WS-A
     CALL "BE7-HAS-MOB" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 4)
     MOVE 0 TO BE-XI(WS-IDX, 5)
     MOVE 2 TO WS-A
     CALL "BE7-HAS-MOB" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 4)
     MOVE 0 TO BE-XI(WS-IDX, 5)
     MOVE 0 TO WS-A
     CALL "BE7-HAS-MOB" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 0 TO BE-XI(WS-IDX, 5)
     MOVE 0 TO WS-A
     CALL "BE7-HAS-MOB" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: ominous item loot seed (4.3 item 11): level seed + the packed BlockPos of (floor(x / 30.0f), floor(y / 20.0f), floor(z / 30.0f)) (shown modulo 1000000007)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1000 TO WS-LONG1
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1000 TO WS-LONG1
     MOVE 59 TO WS-A
     MOVE 39 TO WS-B
     MOVE 61 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE -5 TO WS-LONG1
     MOVE -1 TO WS-A
     MOVE -1 TO WS-B
     MOVE -1 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE 123456789 TO WS-LONG1
     MOVE 300 TO WS-A
     MOVE 200 TO WS-B
     MOVE -301 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE 9223372036854775800 TO WS-LONG1
     MOVE 30 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE -9223372036854775800 TO WS-LONG1
     MOVE -30 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-ITEM-SEED" USING WS-LONG1 WS-A WS-B WS-C WS-LONG2
     MOVE FUNCTION MOD(WS-LONG2, 1000000007) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1000 877914219 1000000001 780366966 586733014 413266993" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§4 Trial spawner: lenient lists and inline configuration (4.1): a list of strings is no player set, an int array of 3 is no UUID, a configuration key of the wrong tag type fails the configuration, an inline" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "registered_players" TO WS-NM
     MOVE 18 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "a" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "b" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "current_mobs" TO WS-NM
     MOVE 12 TO WS-NML
     MOVE 11 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "a:b" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:trial_spawner" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 43 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "normal_config" TO WS-NM
     MOVE 13 TO WS-NML
     PERFORM NB-C
     MOVE "x" TO WS-NM
     MOVE 1 TO WS-NML
     MOVE "y" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "ominous_config" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE "a:o" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0," &
         "target_cooldown_length:36000,required_player_range:14} 0 0 {registered_players:[],current_mobs:[],co" &
         "oldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,ominous_config:a:o,target_cooldown_length" &
         ":36000,required_player_range:14}" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-7-4.

 COPY CORETEST.
