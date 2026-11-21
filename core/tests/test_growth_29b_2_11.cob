*> Test of 29b part 2 section 11, Mangrove propagule, azalea, saplings (core/src/growth-29b-2c.cob; T0555): the propagule, azalea and saplings of 11.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-11.
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
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: propagule outline column(2, SHAPE_MIN_Y[i], 16): minimum y 13, 10, 7, 3, 0 by age when hanging, 0 when standing" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "3 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "4 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SHAPE" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "13/2/16 10/2/16 7/2/16 3/2/16 0/2/16 0/2/16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: propagule survive, placement, updateShape (11.1): tag below if standing, leaves above if hanging; placed at age 4; water tick" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SURVIVE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SURVIVE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SURVIVE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 0 0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SURVIVE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-SURVIVE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/0/0/0/4/0 0/1/0/0/4/0 1/0/1/0/4/0 1/0/0/1/4/0 0/0/0/0/4/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: propagule random tick and bone meal (11.1): standing 1/7 advances the tree with no light test; hanging grows to age 4; bone meal is valid unless hanging and age 4" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "4 0 0 449999" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-TICK" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "4 0 3 450000" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-TICK" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-TICK" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "4 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-TICK" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 5 100000" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-TICK" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/4/1/1/2/4 0/4/1/0/2/4 2/3/1/1/1/3 0/4/0/0/2/4 0/0/1/1/2/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: createNewHangingPropagule (11.1): the default state with hanging true and the given age (0 by default)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-NEW" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-PROP-NEW" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0/1/0/0 3/1/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: azalea (11.2): bone meal on a server needs pos.above(minH + 2) inside the build height and no fluid above; success below 0.45; the tree is grown" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0 1 1 449999 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-AZALEA" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1 3 1 1 450000 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-AZALEA" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-AZALEA" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0 1 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-AZALEA" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1 0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-AZALEA" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/1/2 1/0/0/1/5 0/1/0/0/2 0/1/0/1/2 0/1/0/1/2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: the nine saplings use the growers of part 1 (oak 1, spruce 2, birch 5, jungle 6, acacia 7, cherry 8, dark oak 9, pale oak 10, poplar 11, METAL)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:oak_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:spruce_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:birch_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:jungle_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:acacia_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:cherry_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:dark_oak_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:pale_oak_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:poplar_sapling" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/0/0 2/1/0/0 5/1/0/0 6/1/0/0 7/1/0/0 8/1/0/0 9/1/0/0 10/1/0/0 11/1/1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§11 Mangrove propagule, azalea, saplings: the propagule uses the mangrove grower (3) with the XZ offset; azalea and flowering azalea the azalea grower (4); other blocks have no grower" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:mangrove_propagule" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:azalea" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:flowering_azalea" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE SPACES TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GB2-SAPLING-KIND" USING WS-KEY WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3/2/0/1 4/3/0/0 4/3/0/0 0/0/0/0" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-2-11.
