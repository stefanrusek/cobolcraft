*> Test of 29b part 2 section 1, Registry names covered (core/src/growth-29b-2.cob; T0535): the block table of 1.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-1.
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
     MOVE "acceptance US12 29b-2§1 Registry names covered: crops, pitcher and torchflower: sections 3 and 4, random ticks and instabreak (flags of the registrations)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:wheat" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:carrots" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:potatoes" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:beetroots" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:torchflower_crop" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pitcher_crop" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "30/1/1 30/1/1 30/1/1 33/1/1 34/1/1 40/1/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§1 Registry names covered: stems, attached stems (no random ticks), pumpkin and melon (plain blocks): section 5" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pumpkin_stem" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:melon_stem" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:attached_pumpkin_stem" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:attached_melon_stem" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pumpkin" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:melon" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "51/1/1 52/1/1 53/0/1 53/0/1 54/0/0 54/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§1 Registry names covered: nether wart, cocoa, berry bush, farmland: sections 6 to 9, random ticks and no instabreak" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:nether_wart" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cocoa" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:sweet_berry_bush" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "60/1/0 70/1/0 80/1/0 90/1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§1 Registry names covered: dirt path (no random ticks), mud, rooted dirt: sections 10.1 to 10.3" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dirt_path" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mud" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:rooted_dirt" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "101/0/0 102/0/0 103/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§1 Registry names covered: mangrove propagule, azalea and flowering azalea: sections 11.1 and 11.2" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mangrove_propagule" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:azalea" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowering_azalea" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "111/1/1 112/0/1 112/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§1 Registry names covered: the nine saplings (11.3) tick and break at once; a block of no section gives 0" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:spruce_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:birch_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:jungle_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:acacia_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cherry_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dark_oak_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:poplar_sapling" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-BLOCK" USING WS-KEY WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "113/1/1 113/1/1 113/1/1 113/1/1 113/1/1 113/1/1 113/1/1 113/1/1 113/1/1 0/0/0" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-2-1.
