*> Test of 29b part 4 section 1, Scope, ownership and class table (core/src/growth-29b-4.cob; T0581): the registry names and classes of 1.2 (block to section, random-tick flag) and the spot-checked rows.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-I as integers and WS-FX as doubles), calls the program
*> and shows the outputs WS-R(1..WS-N) joined by "/", one group per call; expected values come from the rules and tables of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY INTERACT.
 01 WS-ISG.
    05 WS-I1 BINARY-LONG.
    05 WS-I2 BINARY-LONG.
    05 WS-I3 BINARY-LONG.
    05 WS-I4 BINARY-LONG.
    05 WS-I5 BINARY-LONG.
    05 WS-I6 BINARY-LONG.
    05 WS-I7 BINARY-LONG.
    05 WS-I8 BINARY-LONG.
    05 WS-I9 BINARY-LONG.
    05 WS-I10 BINARY-LONG.
    05 WS-I11 BINARY-LONG.
    05 WS-I12 BINARY-LONG.
    05 WS-I13 BINARY-LONG.
    05 WS-I14 BINARY-LONG.
    05 WS-I15 BINARY-LONG.
    05 WS-I16 BINARY-LONG.
 01 WS-IST REDEFINES WS-ISG.
    05 WS-I BINARY-LONG OCCURS 16 TIMES.
 01 WS-FXSG.
    05 WS-FX1 FLOAT-LONG.
    05 WS-FX2 FLOAT-LONG.
    05 WS-FX3 FLOAT-LONG.
    05 WS-FX4 FLOAT-LONG.
    05 WS-FX5 FLOAT-LONG.
    05 WS-FX6 FLOAT-LONG.
    05 WS-FX7 FLOAT-LONG.
    05 WS-FX8 FLOAT-LONG.
    05 WS-FX9 FLOAT-LONG.
    05 WS-FX10 FLOAT-LONG.
    05 WS-FX11 FLOAT-LONG.
    05 WS-FX12 FLOAT-LONG.
    05 WS-FX13 FLOAT-LONG.
    05 WS-FX14 FLOAT-LONG.
    05 WS-FX15 FLOAT-LONG.
    05 WS-FX16 FLOAT-LONG.
 01 WS-FXST REDEFINES WS-FXSG.
    05 WS-FX FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RSG.
    05 WS-R1 BINARY-LONG.
    05 WS-R2 BINARY-LONG.
    05 WS-R3 BINARY-LONG.
    05 WS-R4 BINARY-LONG.
    05 WS-R5 BINARY-LONG.
    05 WS-R6 BINARY-LONG.
    05 WS-R7 BINARY-LONG.
    05 WS-R8 BINARY-LONG.
    05 WS-R9 BINARY-LONG.
    05 WS-R10 BINARY-LONG.
    05 WS-R11 BINARY-LONG.
    05 WS-R12 BINARY-LONG.
    05 WS-R13 BINARY-LONG.
    05 WS-R14 BINARY-LONG.
    05 WS-R15 BINARY-LONG.
    05 WS-R16 BINARY-LONG.
 01 WS-RST REDEFINES WS-RSG.
    05 WS-R BINARY-LONG OCCURS 16 TIMES.
 01 WS-RFSG.
    05 WS-RF1 FLOAT-LONG.
    05 WS-RF2 FLOAT-LONG.
    05 WS-RF3 FLOAT-LONG.
    05 WS-RF4 FLOAT-LONG.
    05 WS-RF5 FLOAT-LONG.
    05 WS-RF6 FLOAT-LONG.
    05 WS-RF7 FLOAT-LONG.
    05 WS-RF8 FLOAT-LONG.
 01 WS-RFST REDEFINES WS-RFSG.
    05 WS-RF FLOAT-LONG OCCURS 8 TIMES.
 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-TEXTS.
    05 WS-T1               PIC X(96).
    05 WS-T2               PIC X(96).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry names of 1.2 map to their section x10 (3.3 is 33, 5.1 is 51, 10.1 is 101; part 1 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:kelp" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:kelp_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:weeping_vines" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:weeping_vines_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:twisting_vines" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:twisting_vines_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cave_vines" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cave_vines_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sugar_cane" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus_flower" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:vine" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:chorus_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:chorus_flower" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:seagrass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_seagrass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:short_grass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:fern" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "33 33 34 34 34 34 35 35 40 51 52 60 60 70 81 82 92 93 95 95" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry random-tick flag and the per-state condition of 1.2 (0 none, 1 stage == 0, 2 age < 5, 3 age < 25; part 1 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:kelp" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:kelp_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:weeping_vines" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:weeping_vines_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:twisting_vines" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:twisting_vines_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cave_vines" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cave_vines_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sugar_cane" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus_flower" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:vine" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:chorus_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:chorus_flower" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:seagrass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_seagrass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:short_grass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:fern" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1/3 0/0 1/3 0/0 1/3 0/0 1/3 0/0 1/0 1/0 0/0 1/1 1/0 1/0 0/0 1/2 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry names of 1.2 map to their section x10 (3.3 is 33, 5.1 is 51, 10.1 is 101; part 2 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_grass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:large_fern" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pitcher_plant" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sunflower" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lilac" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rose_bush" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:peony" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dandelion" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:golden_dandelion" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:torchflower" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:poppy" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:blue_orchid" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:allium" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:azure_bluet" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_tulip" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:orange_tulip" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_tulip" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_tulip" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oxeye_daisy" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cornflower" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "91 91 91 96 96 96 96 101 101 101 101 101 101 101 101 101 101 101 101 101" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry random-tick flag and the per-state condition of 1.2 (0 none, 1 stage == 0, 2 age < 5, 3 age < 25; part 2 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_grass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:large_fern" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pitcher_plant" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sunflower" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lilac" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rose_bush" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:peony" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dandelion" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:golden_dandelion" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:torchflower" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:poppy" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:blue_orchid" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:allium" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:azure_bluet" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_tulip" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:orange_tulip" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_tulip" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_tulip" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oxeye_daisy" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cornflower" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry names of 1.2 map to their section x10 (3.3 is 33, 5.1 is 51, 10.1 is 101; part 3 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lily_of_the_valley" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wither_rose" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:open_eyeblossom" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:closed_eyeblossom" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_petals" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wildflowers" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bush" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_shrub" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_bush" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:short_dry_grass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_dry_grass" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:firefly_bush" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sea_pickle" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lily_pad" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:big_dripleaf" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:big_dripleaf_stem" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:small_dripleaf" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:hanging_roots" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:spore_blossom" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_hanging_moss" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "101 102 103 103 104 104 105 105 106 106 106 107 111 112 121 122 124 131 132 133" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry random-tick flag and the per-state condition of 1.2 (0 none, 1 stage == 0, 2 age < 5, 3 age < 25; part 3 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lily_of_the_valley" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wither_rose" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:open_eyeblossom" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:closed_eyeblossom" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_petals" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wildflowers" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bush" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_shrub" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_bush" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:short_dry_grass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tall_dry_grass" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:firefly_bush" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sea_pickle" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lily_pad" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:big_dripleaf" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:big_dripleaf_stem" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:small_dripleaf" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:hanging_roots" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:spore_blossom" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_hanging_moss" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 0/0 1/0 1/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry names of 1.2 map to their section x10 (3.3 is 33, 5.1 is 51, 10.1 is 101; part 4 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mangrove_roots" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "134 134" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: registry random-tick flag and the per-state condition of 1.2 (0 none, 1 stage == 0, 2 age < 5, 3 age < 25; part 4 of 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mangrove_roots" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: names that are not blocks of this part map to 0 with no random tick" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:leaves" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_sapling" TO WS-T1
     CALL "GC4-PART" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§1 Scope, ownership and class table: names that are not blocks of this part have no random tick (0/0)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_leaves" TO WS-T1
     CALL "GC4-RT-FLAG" USING WS-T1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 LOAD-IN.
     MOVE 1 TO WS-P
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE SPACES TO WS-TOK
         IF WS-P <= 160
             UNSTRING WS-IN DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-P
         END-IF
         COMPUTE WS-FX(WS-K) = FUNCTION NUMVAL(WS-TOK)
         COMPUTE WS-I(WS-K) = FUNCTION NUMVAL(WS-TOK)
     END-PERFORM
     .

 ADD-N.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         MOVE WS-R(WS-J) TO WS-SHOW
         IF WS-J > 1
             STRING "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 ADD-TEXT.
     STRING FUNCTION TRIM(WS-T1) "|" FUNCTION TRIM(WS-T2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-GROWTH-29B-4-1.
