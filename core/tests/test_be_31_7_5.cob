*> Test of 31-7 section 5, Vault (core/src/be-31-7.cob; T0963): saved config, shared and server data, the update tag, the state machine, key insertion, display and ejection.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-7-5.
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
     MOVE "acceptance US12 31-7§5 Vault: fresh vault (5.2, 5.3): the default config (loot table minecraft:chests/trial_chambers/reward, ranges 4.0 and 4.5, key minecraft:trial_key x 1), empty shared and server data; the keys are config," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range" &
         ":4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{connected_players:[],connected_partic" &
         "les_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],tota" &
         "l_ejections_needed:0}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: round trip (5.2, 5.3): config, shared_data and server_data load and save back; total_ejections_needed is saved but not restored (the quirk of 5.3, so the next save holds 0)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "config" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "loot_table" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "a:loot" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     MOVE "activation_range" TO WS-NM
     MOVE 16 TO WS-NML
     COMPUTE WS-FA = 1.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "deactivation_range" TO WS-NM
     MOVE 18 TO WS-NML
     COMPUTE WS-FA = 2.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "key_item" TO WS-NM
     MOVE 8 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:key" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "override_loot_table_to_display" TO WS-NM
     MOVE 30 TO WS-NML
     MOVE "a:show" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "shared_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "display_item" TO WS-NM
     MOVE 12 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:gem" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "connected_players" TO WS-NM
     MOVE 17 TO WS-NML
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
     MOVE "connected_particles_range" TO WS-NM
     MOVE 25 TO WS-NML
     COMPUTE WS-FA = 3.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     PERFORM NB-E
     MOVE "server_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "rewarded_players" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 11 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 9 TO WS-IAV(1)
     MOVE 8 TO WS-IAV(2)
     MOVE 7 TO WS-IAV(3)
     MOVE 6 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 4 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 2 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE "state_updating_resumes_at" TO WS-NM
     MOVE 25 TO WS-NML
     MOVE 500 TO WS-LV
     PERFORM NB-LONG
     MOVE "items_to_eject" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:x" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:y" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "total_ejections_needed" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{config:{loot_table:a:loot,activation_range:1.500,deactivation_range:2.500,key_item:{id:a:key,count:" &
         "2},override_loot_table_to_display:a:show},shared_data:{display_item:{id:a:gem,count:3},connected_pla" &
         "yers:[I[1,2,3,4]],connected_particles_range:3.500},server_data:{rewarded_players:[I[9,8,7,6],I[5,4,3" &
         ",2]],state_updating_resumes_at:500,items_to_eject:[{id:a:x,count:1},{id:a:y,count:2}],total_ejection" &
         "s_needed:0}} 2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: config rules (5.2): activation_range above deactivation_range rejects the config (the default); no config keeps the default" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "config" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "activation_range" TO WS-NM
     MOVE 16 TO WS-NML
     COMPUTE WS-FA = 5.0
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "deactivation_range" TO WS-NM
     MOVE 18 TO WS-NML
     COMPUTE WS-FA = 4.0
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "loot_table" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "a:bad" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range" &
         ":4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{connected_players:[],connected_partic" &
         "les_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],tota" &
         "l_ejections_needed:0}} {config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4" &
         ".000,deactivation_range:4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{connected_play" &
         "ers:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0" &
         ",items_to_eject:[],total_ejections_needed:0}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: config rules (5.2): a config without key_item has the empty stack (not written); a display item without a count has count 1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "config" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "loot_table" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "a:ok" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "shared_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "display_item" TO WS-NM
     MOVE 12 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:g" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{config:{loot_table:a:ok,activation_range:4.000,deactivation_range:4.500},shared_data:{connected_pla" &
         "yers:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:" &
         "0,items_to_eject:[],total_ejections_needed:0}} {config:{loot_table:minecraft:chests/trial_chambers/r" &
         "eward,activation_range:4.000,deactivation_range:4.500,key_item:{id:minecraft:trial_key,count:1}},sha" &
         "red_data:{display_item:{id:a:g,count:1},connected_players:[],connected_particles_range:4.500},server" &
         "_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: update tag (5.4): a compound with the single key shared_data; the client config is the default config" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "config" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "loot_table" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "a:loot" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     MOVE "activation_range" TO WS-NM
     MOVE 16 TO WS-NML
     COMPUTE WS-FA = 1.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "deactivation_range" TO WS-NM
     MOVE 18 TO WS-NML
     COMPUTE WS-FA = 2.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     MOVE "key_item" TO WS-NM
     MOVE 8 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:key" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "override_loot_table_to_display" TO WS-NM
     MOVE 30 TO WS-NML
     MOVE "a:show" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "shared_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "display_item" TO WS-NM
     MOVE 12 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:gem" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "connected_players" TO WS-NM
     MOVE 17 TO WS-NML
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
     MOVE "connected_particles_range" TO WS-NM
     MOVE 25 TO WS-NML
     COMPUTE WS-FA = 3.5
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-NM WS-NML WS-FA
     PERFORM NB-E
     MOVE "server_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "rewarded_players" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 11 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 9 TO WS-IAV(1)
     MOVE 8 TO WS-IAV(2)
     MOVE 7 TO WS-IAV(3)
     MOVE 6 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 4 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 2 TO WS-IAV(4)
     MOVE 4 TO WS-LC
     PERFORM NB-IA
     MOVE "state_updating_resumes_at" TO WS-NM
     MOVE 25 TO WS-NML
     MOVE 500 TO WS-LV
     PERFORM NB-LONG
     MOVE "items_to_eject" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:x" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:y" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "total_ejections_needed" TO WS-NM
     MOVE 22 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
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
     MOVE "{shared_data:{display_item:{id:a:gem,count:3},connected_players:[I[1,2,3,4]],connected_particles_ran" &
         "ge:3.500}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: canEjectReward (5.7): the key item is not empty and the state is not inactive (key length, state in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 19 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO WS-A
     CALL "BE7-VAULT-CAN-EJECT" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 19 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-CAN-EJECT" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 19 TO BE-XI(WS-IDX, 1)
     MOVE 3 TO WS-A
     CALL "BE7-VAULT-CAN-EJECT" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-CAN-EJECT" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: setDisplayItem (5.7): no change when the stack matches the current one (id and count), otherwise the stack is stored and the shared data is dirty (changed out)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE SPACES TO WS-T64
     MOVE "a:gem" TO WS-T64
     MOVE 5 TO WS-LEN
     MOVE 3 TO WS-B
     CALL "BE7-VAULT-SET-DISPLAY" USING WS-IDX WS-T64 WS-LEN WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO BE-XI(WS-IDX, 61)
     CALL "BE7-VAULT-SET-DISPLAY" USING WS-IDX WS-T64 WS-LEN WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-B
     CALL "BE7-VAULT-SET-DISPLAY" USING WS-IDX WS-T64 WS-LEN WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 0 0 1 4 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: state tick (5.5, example 7.8): inactive and active move by the connected players and wait 20 ticks; unlocking goes to ejecting and waits 20; ejecting with items pops the last one with progress 1 - (k" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 3 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 59)
     MOVE 3 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 59)
     MOVE 1 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE 1000 TO WS-LONG1
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FS1) * 10000
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 60) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 0 1020 0 0 0 0 0 1020 1 0 0 0 0 1020 0 0 0 0 0 1020 3 0 0 0 3 1020 3 1 0 2 3 1020 3 1 5000 1" &
         " 3 1020 3 1 10000 0 3 1020 1 0 0 0 0 1020 0 0 0 0 0 1020 3 1 10000 0 1 1020 3 1 20000 1 0 1020" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: eject sound (5.7, example 7.8): pitch 0.8 + 0.4 * progress (0.8, 1.0, 1.2 and 1.6 after a reload)" TO TL-CASE
     PERFORM BEGIN-CASE
     COMPUTE WS-FS1 = 0.0
     CALL "BE7-VAULT-PITCH" USING WS-FS1 WS-FS2
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     COMPUTE WS-FS1 = 0.5
     CALL "BE7-VAULT-PITCH" USING WS-FS1 WS-FS2
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     COMPUTE WS-FS1 = 1.0
     CALL "BE7-VAULT-PITCH" USING WS-FS1 WS-FS2
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     COMPUTE WS-FS1 = 2.0
     CALL "BE7-VAULT-PITCH" USING WS-FS1 WS-FS2
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     MOVE "8000 10000 12000 16000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: display after a pop (5.5): the new last item becomes the display item, the empty stack when none is left" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 3 TO BE-XI(WS-IDX, 59)
     MOVE 0 TO BE-XI(WS-IDX, 60)
     MOVE "a:i1" TO BE-XT(WS-IDX, 5)
     MOVE "a:i2" TO BE-XT(WS-IDX, 6)
     MOVE "a:i3" TO BE-XT(WS-IDX, 7)
     MOVE 4 TO BE-XI(WS-IDX, 6)
     MOVE 1000 TO WS-LONG1
     MOVE 3 TO WS-A
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     STRING BE-XT(WS-IDX, 4)(1:BE-XI(WS-IDX, 6)) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     CALL "BE7-VAULT-NEXT" USING WS-IDX WS-LONG1 WS-A WS-B WS-C WS-E WS-FS1
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "a:i2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: tick order (5.5): the display cycle runs when the game time is a multiple of 20 and the state is active; the state tick when the game time reaches state_updating_resumes_at" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 40 TO WS-LONG1
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-GATE" USING WS-LONG1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 41 TO WS-LONG1
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-GATE" USING WS-LONG1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 40 TO WS-LONG1
     MOVE 0 TO WS-A
     CALL "BE7-VAULT-GATE" USING WS-LONG1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 60 TO WS-LONG1
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-GATE" USING WS-LONG1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-LONG1
     MOVE 10 TO WS-LONG2
     CALL "BE7-VAULT-DUE" USING WS-LONG1 WS-LONG2 WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 9 TO WS-LONG1
     MOVE 10 TO WS-LONG2
     CALL "BE7-VAULT-DUE" USING WS-LONG1 WS-LONG2 WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 11 TO WS-LONG1
     MOVE 10 TO WS-LONG2
     CALL "BE7-VAULT-DUE" USING WS-LONG1 WS-LONG2 WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 1 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: synchronisation (5.4): a dirty server data or shared data marks the chunk unsaved, only a dirty shared data is sent, both flags are cleared (shared dirty, server dirty in; set changed, send out)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 61)
     MOVE 0 TO BE-XI(WS-IDX, 62)
     CALL "BE7-VAULT-SYNC" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 62) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 61)
     MOVE 1 TO BE-XI(WS-IDX, 62)
     CALL "BE7-VAULT-SYNC" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 62) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 61)
     MOVE 0 TO BE-XI(WS-IDX, 62)
     CALL "BE7-VAULT-SYNC" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 62) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 61)
     MOVE 1 TO BE-XI(WS-IDX, 62)
     CALL "BE7-VAULT-SYNC" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 62) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 0 1 0 0 0 1 1 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: transition hooks (5.5): entering inactive sends level event 3016 and entering active 3015 (data 1 when ominous, active also runs the display cycle when there is no display item), entering unlocking" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "3016 0 0 0 0 3016 1 0 0 0 3015 0 0 0 1 3015 1 0 0 1 0 0 1 0 0 0 0 2 0 0 3015 0 0 3 1 3016 1 0 3 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: transition hooks (5.5): entering active with a display item already set does not run the cycle" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 6)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE7-VAULT-HOOK" USING WS-IDX WS-B WS-A WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: key insertion (5.6, example 7.9): nothing without a key item or in the inactive state; a stack of another item or too few fails with the insert-fail sound; a player that already took a reward gets" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 0 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:o" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 95 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE 7 TO BE-UUID(WS-IDX, 1)
     MOVE 7 TO BE-UUID(WS-IDX, 2)
     MOVE 7 TO BE-UUID(WS-IDX, 3)
     MOVE 7 TO BE-UUID(WS-IDX, 4)
     MOVE 1 TO BE-XI(WS-IDX, 25)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 90 TO BE-TIME2(WS-IDX)
     MOVE 7 TO BE-UUID(WS-IDX, 1)
     MOVE 7 TO BE-UUID(WS-IDX, 2)
     MOVE 7 TO BE-UUID(WS-IDX, 3)
     MOVE 7 TO BE-UUID(WS-IDX, 4)
     MOVE 1 TO BE-XI(WS-IDX, 25)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "a:k" TO BE-XT(WS-IDX, 1)
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO BE-TIME2(WS-IDX)
     MOVE SPACES TO WS-T64
     MOVE "a:k" TO WS-T64
     MOVE 100 TO WS-LONG1
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 1 TO WS-C
     MOVE 2 TO WS-E
     MOVE 7 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 7 TO WS-TV(3)
     MOVE 7 TO WS-TV(4)
     CALL "BE7-VAULT-KEY" USING WS-IDX WS-A WS-LONG1 WS-T64 WS-LEN WS-B WS-C WS-TAB WS-E WS-F WS-G WS-H
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-TIME2(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE "4 0 2 0 3 114 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 100 0 0 0 1 1 0 100 0 0 0 4 0 2 95 3 114 1 2 1 0 1" &
         "00 0 0 1 2 0 0 90 0 0 1 3 0 0 0 0 0 0 4 0 2 0 3 114 1 4 0 0 0 2 114 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: rewarded set (5.6 step 8, validation 17): an insertion-ordered set of at most 128; a 129th member drops the oldest; an already present player is not added again; the server data is dirty" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 128 TO BE-XI(WS-IDX, 25)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 128
     COMPUTE WS-J = (WS-K - 1) * 4
     MOVE WS-K TO BE-UUID(WS-IDX, WS-J + 1)
     MOVE 0 TO BE-UUID(WS-IDX, WS-J + 2) BE-UUID(WS-IDX, WS-J + 3) BE-UUID(WS-IDX, WS-J + 4)
     END-PERFORM
     MOVE 999 TO WS-TV(1)
     MOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)
     CALL "BE7-VAULT-REWARD" USING WS-IDX WS-TAB
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 509) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 62) TO WS-SHOW
     PERFORM ADD-N
     CALL "BE7-VAULT-REWARD" USING WS-IDX WS-TAB
     MOVE BE-XI(WS-IDX, 25) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "128 2 999 1 128 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: connected players (5.5): the detected players that are not in the rewarded set replace the stored set when it differs (shared data dirty); a rewarded player never keeps the vault active (candidates" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 25)
     MOVE 0 TO BE-XI(WS-IDX, 8)
     MOVE 1 TO WS-TV(1)
     MOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-CONNECT" USING WS-IDX WS-TAB WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 25)
     MOVE 1 TO BE-XI(WS-IDX, 8)
     MOVE 1 TO BE-UUID(WS-IDX, 513)
     MOVE 0 TO BE-UUID(WS-IDX, 514) BE-UUID(WS-IDX, 515) BE-UUID(WS-IDX, 516)
     MOVE 1 TO WS-TV(1)
     MOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-CONNECT" USING WS-IDX WS-TAB WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 25)
     MOVE 0 TO BE-XI(WS-IDX, 8)
     MOVE 2 TO BE-UUID(WS-IDX, 1)
     MOVE 0 TO BE-UUID(WS-IDX, 2) BE-UUID(WS-IDX, 3) BE-UUID(WS-IDX, 4)
     MOVE 1 TO WS-TV(1)
     MOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)
     MOVE 2 TO WS-TV(5)
     MOVE 0 TO WS-TV(6) WS-TV(7) WS-TV(8)
     MOVE 2 TO WS-A
     CALL "BE7-VAULT-CONNECT" USING WS-IDX WS-TAB WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 25)
     MOVE 1 TO BE-XI(WS-IDX, 8)
     MOVE 2 TO BE-UUID(WS-IDX, 1)
     MOVE 0 TO BE-UUID(WS-IDX, 2) BE-UUID(WS-IDX, 3) BE-UUID(WS-IDX, 4)
     MOVE 2 TO BE-UUID(WS-IDX, 513)
     MOVE 0 TO BE-UUID(WS-IDX, 514) BE-UUID(WS-IDX, 515) BE-UUID(WS-IDX, 516)
     MOVE 2 TO WS-TV(1)
     MOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)
     MOVE 1 TO WS-A
     CALL "BE7-VAULT-CONNECT" USING WS-IDX WS-TAB WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 61) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 1 0 1 1 0 1 1 1 1 1 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: ranges (5.5, example 7.10): a player connects when its squared distance is below the range squared (13 below 16 at 4.0; 17 and 20 below 20.25 stay, 25 drops at 4.5) (distance squared, range in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 13 TO WS-A
     COMPUTE WS-FA = 4.0
     CALL "BE7-VAULT-RANGE" USING WS-A WS-FA WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 17 TO WS-A
     COMPUTE WS-FA = 4.5
     CALL "BE7-VAULT-RANGE" USING WS-A WS-FA WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 4.5
     CALL "BE7-VAULT-RANGE" USING WS-A WS-FA WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 25 TO WS-A
     COMPUTE WS-FA = 4.5
     CALL "BE7-VAULT-RANGE" USING WS-A WS-FA WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-A
     COMPUTE WS-FA = 4.0
     CALL "BE7-VAULT-RANGE" USING WS-A WS-FA WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: unknown keys (5.3): keys the vault parts do not know are skipped; a key item with an extra key keeps its id and count; a list of the wrong element type gives no items to eject" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "config" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "key_item" TO WS-NM
     MOVE 8 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:k" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "extra" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "z" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM NB-E
     MOVE "shared_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "server_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "items_to_eject" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE 3 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 7 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE 3 TO WS-A
     MOVE "{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range" &
         ":4.500,key_item:{id:a:k,count:1}},shared_data:{connected_players:[],connected_particles_range:4.500}" &
         ",server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_need" &
         "ed:0}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§5 Vault: items to eject (5.3): at most 8 stacks are kept (the cells of this implementation), in list order" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:vault" TO WS-KEY
     MOVE 15 TO WS-SVL
     MOVE 44 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "server_data" TO WS-NM
     MOVE 11 TO WS-NML
     PERFORM NB-C
     MOVE "items_to_eject" TO WS-NM
     MOVE 14 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 9 TO WS-LC
     PERFORM NB-L
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i0" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i1" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i2" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i3" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 4 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i4" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i5" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 6 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i6" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 7 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i7" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 8 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "a:i8" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 9 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE BE-XI(WS-IDX, 59) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE "8 8" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-7-5.

 COPY CORETEST.
