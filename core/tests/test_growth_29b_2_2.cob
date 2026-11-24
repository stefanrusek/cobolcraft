*> Test of 29b part 2 section 2, Tags and shared vocabulary (core/src/growth-29b-2.cob; T0537): the tags and vocabulary of 2.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ISG.
    05 WS-I BINARY-LONG OCCURS 16 TIMES.
 01 WS-RSG.
    05 WS-R BINARY-LONG OCCURS 16 TIMES.
 01 WS-KEY                 PIC X(48).
 01 WS-A                   PIC X(48).
 01 WS-B                   PIC X(48).
 01 WS-C                   PIC X(48).
 01 WS-STEM                BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: vocabulary (2.1): rawBrightness is max(block, sky); the local value darkens the sky term (not below 0)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "5 12 4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-VOCAB" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "14 3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-VOCAB" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 15 15" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-VOCAB" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 2 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-VOCAB" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "12/8 14/14 15/0 2/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: supports_crops, grows_crops and the stem support tags hold farmland only (2.2)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "9 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "10 0 0 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: supports_vegetation: #substrate_overworld (dirt, mud, moss, grass) and farmland; the fruit tags are the same set" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 1 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 0 1 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 0 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11 0 0 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "12 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "11 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 1 0 1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: substrate_overworld excludes farmland; supports_azalea and supports_mangrove_propagule add clay" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "4 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "4 0 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 0 1 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moss_block" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:clay" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6 1 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "6 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 1 1 1 0 1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: supports_cocoa (jungle logs), supports_nether_wart (soul sand), supports_hanging_mangrove_propagule (mangrove leaves)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "7 0 0 0 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:jungle_log" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "7 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_log" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:soul_sand" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "8 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:netherrack" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mangrove_leaves" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "14 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_leaves" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§2 Tags and shared vocabulary: maintains_farmland lists the stems, crops, flowers, the moving piston and every fence gate" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pumpkin_stem" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:attached_pumpkin_stem" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:melon_stem" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:attached_melon_stem" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:beetroots" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:carrots" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:potatoes" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:torchflower_crop" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:torchflower" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pitcher_crop" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wheat" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:moving_piston" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 1" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_fence_gate" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "13 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-TAG" USING WS-ISG WS-KEY WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 1 1 1 1 1 1 1 1 1 0 0" TO TL-EXPECTED
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
     STRING FUNCTION TRIM(WS-A) "|" FUNCTION TRIM(WS-B) "|" FUNCTION TRIM(WS-C) "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-T1 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-T2 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-GROWTH-29B-2-2.
