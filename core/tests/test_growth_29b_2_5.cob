*> Test of 29b part 2 section 5, Stems, fruit, attached stems, pumpkin and melon (core/src/growth-29b-2.cob; T0543): the stems, fruit and carving of 5.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-5.
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
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: stem constants (5.1): fruit, attached stem, seed, support tag numbers (9 and 10 stem support, 11 and 12 fruit support)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-STEM
     CALL "GB2-STEM-NAMES" USING WS-STEM WS-A WS-B WS-C WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE 2 TO WS-STEM
     CALL "GB2-STEM-NAMES" USING WS-STEM WS-A WS-B WS-C WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "minecraft:pumpkin|minecraft:attached_pumpkin_stem|minecraft:pumpkin_seeds|9/11 minecraft:melon|minecraft:attached_melon_stem|minecraft:melon_seeds|10/12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: stem shape column(2, 0, 2 + 2a), survival on the support tag with no light test, every state random ticks" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-STATE" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-STATE" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "7 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-STATE" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "2/2/1/1 2/8/1/1 2/16/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: random tick (5.2): light below 9 stops without a draw; one growth draw; an age below 7 gains 1 (action 1); bound int(25 / speed) + 1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "8 3 1000 0 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "9 3 1000 0 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "9 3 200 5 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 6 1000 0 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0/0/3/0/0 1/3/4/0/1 0/13/3/0/1 1/3/7/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: mature stem (14.4): direction draw picks N, E, S, W (2, 5, 3, 4); fruit and attached stem need air, fruit soil, both blocks" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "12 7 1000 0 2 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 1 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 3 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 2 0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 2 1 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 0 2 1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "12 7 1000 1 2 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-TICK" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "2/3/7/3/2 2/3/7/2/2 2/3/7/5/2 2/3/7/4/2 0/3/7/3/2 0/3/7/3/2 0/3/7/3/2 0/3/7/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: bone meal (5, 13, 14.4): age + U(2, 5) capped at 7, valid unless age 7, always succeeds; the result 7 runs one random tick at once" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "5 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "4 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "3 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "7 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-BONE" USING WS-ISG WS-RSG
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/7/1/1 1/1/2/0/1 1/1/7/1/1 1/1/7/1/1 1/1/5/0/1 0/1/7/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: attached stems (5.3, 14.5): a non-fruit neighbour at facing reverts to the stem at age 7; other directions and the fruit change nothing" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 3 0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-ATTACHED" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "2 3 0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-ATTACHED" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3 3 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-ATTACHED" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3 3 0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-ATTACHED" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "3 3 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-ATTACHED" USING WS-ISG WS-RSG
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/7/1/1 0/0/1/1 0/0/1/1 0/0/1/1 1/7/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: seed counts of the shipped loot tables (5.3): binomial n 3 with p (age + 1) / 15 for stems, 0.53333336 for attached stems" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 4" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 6" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 7" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-STEM-SEEDS" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "3/66667 3/133333 3/200000 3/266667 3/333333 3/400000 3/466667 3/533333 3/533333" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§5 Stems, fruit, attached stems, pumpkin and melon: carving a pumpkin with shears (5.4): facing is the clicked side or the player's opposite; flags 11, durability 1, item offset, delta" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 2 3 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 5 500 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "1 2 3 0 100" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 4 1000 500" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "1 3 2 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "1 4 2 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-CARVE" USING WS-ISG WS-RSG
     MOVE 10 TO WS-N
     PERFORM ADD-N
     MOVE "0/0/0/0/0/0/0/0/0/0 1/5/11/1/1150/100/500/60000/50000/0 1/2/11/1/500/100/-150/0/50000/-48000 1/4/11/1/-150/100/500/-30000/50000/10000 1/3/11/1/500/100/1150/0/50000/50000 1/4/11/1/-150/100/500/-50000/50000/0" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-2-5.
