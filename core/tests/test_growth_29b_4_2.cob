*> Test of 29b part 4 section 2, Shared base, helpers and vocabulary (core/src/growth-29b-4.cob; T0583): VegetationBlock and BushBlock (2.1, 2.2), the helpers of 2.3, the tags of 2.4 and the flags of 2.5.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-I as integers and WS-FX as doubles), calls the program
*> and shows the outputs WS-R(1..WS-N) joined by "/", one group per call; expected values come from the rules and tables of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-4-2.
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
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_vegetation (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 1 0 0 0 1 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_vegetation (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag substrate_overworld (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag substrate_overworld (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag dirt (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag dirt (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag sand (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag sand (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane_adjacently (block) (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane_adjacently (block) (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_cactus (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_cactus (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag support_override_cactus_flower (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag support_override_cactus_flower (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_bamboo (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 0 0 1 0 1 0 0 0 0 0 1 1 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_bamboo (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 1 1 1 0 0 0 0 0 1 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag cannot_support_kelp and cannot_support_seagrass (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag cannot_support_kelp and cannot_support_seagrass (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_chorus_plant and supports_chorus_flower (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_chorus_plant and supports_chorus_flower (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_dry_vegetation (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:brown_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cyan_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:green_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 1 1 0 0 1 1 0 1 0 1 0 0 0 1 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_dry_vegetation (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lime_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magenta_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:orange_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:purple_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 0 1 1 0 0 0 0 1 0 0 0 1 0 1 1 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_dry_vegetation (2.4): members and non-members (part 3)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:yellow_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 1 1 0 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag terracotta (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:brown_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cyan_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:green_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag terracotta (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lime_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magenta_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:orange_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:purple_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 0 0 0 0 0 0 0 1 0 0 0 1 0 1 0 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag terracotta (2.4): members and non-members (part 3)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:yellow_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 0 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_wither_rose (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 1 0 0 0 1 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_wither_rose (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_lily_pad (block) (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_lily_pad (block) (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "15" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_small_dripleaf (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_small_dripleaf (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "16" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_big_dripleaf (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 1 1 0 1 0 1 0 0 0 1 0 0 0 0 1 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_big_dripleaf (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "17" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag coral_blocks (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:brain_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bubble_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:fire_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:horn_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 1 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag coral_blocks (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag coral_blocks (2.4): members and non-members (part 3)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "18" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag pale_oak_logs (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag pale_oak_logs (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "19" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 1 1 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane_adjacently (fluid, water tag) (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_sugar_cane_adjacently (fluid, water tag) (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "20" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_lily_pad (fluid) (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag supports_lily_pad (fluid) (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "21" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag triggers_ambient_desert_dry_vegetation_block_sounds (2.4): members and non-members (part 1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bamboo_sapling" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:black_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:brown_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cactus" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:coarse_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cyan_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dead_tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:end_stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowing_water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:frosted_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:glazed_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:green_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lava" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag triggers_ambient_desert_dry_vegetation_block_sounds (2.4): members and non-members (part 2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_blue_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:light_gray_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lime_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magenta_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:magma_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:muddy_mangrove_roots" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mycelium" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:orange_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:packed_ice" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pink_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:podzol" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:purple_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 0 0 0 0 0 0 0 1 0 0 0 1 0 1 1 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tag triggers_ambient_desert_dry_vegetation_block_sounds (2.4): members and non-members (part 3)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_soil" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_log" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stripped_pale_oak_wood" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_gravel" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:suspicious_sand" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:tube_coral_block" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:water" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:white_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "22" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:yellow_terracotta" TO WS-T1
     CALL "GC4-IN-TAG" USING WS-I1 WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 0 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: VegetationBlock (2.1): canSurvive is mayPlaceOn of the state below (supports_vegetation); the shape update gives air when it fails," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-RULES" USING WS-I1 WS-R1 WS-R2 WS-R3
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-RULES" USING WS-I1 WS-R1 WS-R2 WS-R3
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/0 0/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: VegetationBlock facts (2.1): propagatesSkylightDown = the fluid state is empty; isPathfindable is true for path type AIR with no" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-FACTS" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-FACTS" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-FACTS" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-FACTS" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-VEG-FACTS" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1/1 0/1 1/-1 1/-1 0/-1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: BushBlock (2.2): shape height 13 unless the constructor passes another; bone meal is the neighbour spreader: valid when a neighbour" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-BUSH-BONE" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-BUSH-BONE" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/3 0/1/1/3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: BushBlock shape (2.2): column height 13 by default, the constructor argument otherwise (bush and red_shrub use 13)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-BUSH-SHAPE" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "13" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-BUSH-SHAPE" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "9" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-BUSH-SHAPE" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "16/13 16/13 16/9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: FlowerBlock extends VegetationBlock, not BushBlock (2.2 correction): only bush and red_shrub use the generic spreader" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:bush" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:red_shrub" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dandelion" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:golden_dandelion" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wither_rose" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:open_eyeblossom" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:closed_eyeblossom" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:poppy" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:firefly_bush" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:short_grass" TO WS-T1
     CALL "GC4-BUSH-CLASS" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: fluid state tests (2.3): isWaterAt is the tag test (source and flowing); FluidState.is(Fluids.WATER) only the still water object;" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLUID" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1 8" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLUID" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "2 8" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLUID" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "2 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLUID" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3 8" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLUID" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0/0/0/0 1/1/1/1 1/0/0/1 1/0/0/0 0/0/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: LiquidBlockContainer (2.3): canPlaceLiquid and placeLiquid both false, the fluid state always a water source (1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-LIQCONT" USING  WS-R1 WS-R2 WS-R3
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "0/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: copyWaterloggedFrom (2.3): with the property waterlogged it takes isWaterAt(pos); without it the state is unchanged (-1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-WATERLOG-COPY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-WATERLOG-COPY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-WATERLOG-COPY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-WATERLOG-COPY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 -1 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: orders (2.3): Plane.HORIZONTAL is north, east, south, west (a random direction is HORIZONTAL[nextInt(4)]); Plane.VERTICAL is up," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 6 4 5 2 1 1 2 3 4 5 6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: clockwise and counter-clockwise (2.3): north to east, east to south, south to west, west to north; the counter-clockwise is the" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "4 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4 6" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4 4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 6" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-HDIR" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6 4 5 3 5 3 6 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: Mth.nextInt(r, a, b) (2.3): a when a >= b, else a + nextInt(b - a + 1) (the draw is the value of nextInt)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-NEXT-INT" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-NEXT-INT" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 5 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-NEXT-INT" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "-10 10 20" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-NEXT-INT" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-NEXT-INT" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 5 5 10 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: Mth.randomBetween(r, a, b) (2.3): nextFloat * (b - a) + a, one draw (x 1000000)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0.8 1.2 0.0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-RAND-BETWEEN" USING WS-FX1 WS-FX2 WS-FX3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0.8 1.2 0.5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-RAND-BETWEEN" USING WS-FX1 WS-FX2 WS-FX3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0.8 1.2 0.25" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-RAND-BETWEEN" USING WS-FX1 WS-FX2 WS-FX3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 2 0.75" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-RAND-BETWEEN" USING WS-FX1 WS-FX2 WS-FX3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "800000 1000000 900000 1500000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: flags and events (2.5): flags 2 clients only, 3 neighbours and clients, 18 = 2 + 16, 35 = 1 + 2 + 32, 260 = 4 + 256; level events" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-FLAG" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 3 18 35 260 1033 1034 2001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: scheduled tick of the non-vegetation blocks (2.1, 14.1): a shape update that finds the block unable to survive schedules a block tick" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SU-TICK" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SU-TICK" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 1/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§2 Shared base, helpers and vocabulary: tick of those blocks (14.1): destroyBlock with drops only when canSurvive is false" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-TICK-REMOVE" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-TICK-REMOVE" USING WS-I1 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/0 1/1" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-4-2.
