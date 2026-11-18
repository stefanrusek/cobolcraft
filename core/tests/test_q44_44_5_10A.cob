*> Further readings (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 10A; lane 002-lane-p49i, T22570; phase task T2746): the Halloween date source and the other special
*> dates, the trigger-block reactions of the explosion hooks, BlockSetType.canOpenByWindCharge, the block resistance setter, check 16 of section 10 (getRandomShortFuse).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-10A.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-M                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG VALUE 80.
 01 WS-N                   BINARY-LONG.
 01 WS-SETS.
    05 FILLER              PIC X(24) VALUE "iron".
    05 FILLER              PIC X(24) VALUE "gold".
    05 FILLER              PIC X(24) VALUE "copper".
    05 FILLER              PIC X(24) VALUE "stone".
    05 FILLER              PIC X(24) VALUE "polished_blackstone".
    05 FILLER              PIC X(24) VALUE "cherry".
    05 FILLER              PIC X(24) VALUE "crimson".
    05 FILLER              PIC X(24) VALUE "warped".
    05 FILLER              PIC X(24) VALUE "bamboo".
    05 FILLER              PIC X(24) VALUE "oak".
    05 FILLER              PIC X(24) VALUE "spruce".
    05 FILLER              PIC X(24) VALUE "birch".
    05 FILLER              PIC X(24) VALUE "acacia".
    05 FILLER              PIC X(24) VALUE "jungle".
    05 FILLER              PIC X(24) VALUE "dark_oak".
    05 FILLER              PIC X(24) VALUE "pale_oak".
    05 FILLER              PIC X(24) VALUE "poplar".
    05 FILLER              PIC X(24) VALUE "mangrove".
 01 WS-SET-TABLE REDEFINES WS-SETS.
    05 WS-SET              PIC X(24) OCCURS 18 TIMES.
 PROCEDURE DIVISION.
*>   1. The special dates (month-day of the host's current date).
     MOVE 10 TO WS-M
     MOVE 31 TO WS-D
     MOVE 1 TO WS-K
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "31 October is Halloween" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 30 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "30 October is not Halloween" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 12 TO WS-M
     MOVE 25 TO WS-D
     MOVE 2 TO WS-K
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "25 December is in the Christmas range 24 to 26" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 27 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "27 December is outside the Christmas range" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-K
     MOVE 24 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "24 December is Christmas" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 25 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "25 December is not CHRISTMAS (24 December only)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-K
     MOVE 1 TO WS-M
     MOVE 1 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "1 January is New Year" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-D
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "2 January is not New Year" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO WS-K
     CALL "Q5-SPECIAL-DATE" USING WS-M WS-D WS-K WS-A
     MOVE "an unknown date kind is false" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   2. canTriggerBlocks.
     CALL "Q5-CAN-TRIGGER" USING WS-L1 WS-L0 WS-L0 WS-A
     MOVE "TRIGGER_BLOCK from a source that is not a breeze wind charge can trigger blocks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-CAN-TRIGGER" USING WS-L1 WS-L1 WS-L0 WS-A
     MOVE "a breeze wind charge needs mob_griefing: off, no trigger" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-CAN-TRIGGER" USING WS-L1 WS-L1 WS-L1 WS-A
     MOVE "a breeze wind charge with mob_griefing on triggers blocks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-CAN-TRIGGER" USING WS-L0 WS-L0 WS-L1 WS-A
     MOVE "another block interaction never triggers blocks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   3. canOpenByWindCharge per block set type: only iron is false.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE WS-SET(WS-I) TO WS-KEY
         CALL "Q5-OPEN-BY-WIND" USING WS-KEY WS-A
         IF WS-A = 1
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "17 of the 18 block set types open by wind charge (all but iron)" TO WS-CASE
     MOVE 17 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "iron" TO WS-KEY
     CALL "Q5-OPEN-BY-WIND" USING WS-KEY WS-A
     MOVE "the iron block set does not open by wind charge" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "netherite" TO WS-KEY
     CALL "Q5-OPEN-BY-WIND" USING WS-KEY WS-A
     MOVE "an unknown block set type is -1" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   4. The reactions (class, can trigger, powered, lower half, canOpenByWindCharge) -> action.
     MOVE 1 TO WS-K
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "a button that is not powered is pressed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L1 WS-L0 WS-L0 WS-A
     MOVE "a powered button does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L0 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "an explosion that cannot trigger blocks does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-K
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L1 WS-L1 WS-A
     MOVE "the lower half of a wind-openable unpowered door toggles open" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L1 WS-A
     MOVE "the upper half of a door does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L1 WS-L0 WS-A
     MOVE "an iron door (canOpenByWindCharge false) does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "a powered door does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-K
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L1 WS-A
     MOVE "a wind-openable unpowered trapdoor toggles open" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "an iron trapdoor does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-K
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "an unpowered fence gate toggles open" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 5 TO WS-K
     CALL "Q5-EXPLOSION-HIT" USING WS-K WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "a bell is rung" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   5. The block resistance setter.
     MOVE -2 TO WS-R
     CALL "Q5-RESISTANCE-SET" USING WS-R WS-S
     MOVE "explosionResistance(-2) stores 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = WS-S * 1000
     PERFORM CHECK-N
     MOVE 1200 TO WS-R
     CALL "Q5-RESISTANCE-SET" USING WS-R WS-S
     MOVE "explosionResistance(1200) (obsidian) stores 1200" TO WS-CASE
     MOVE 1200000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-S * 1000
     PERFORM CHECK-N
*>   6. getRandomShortFuse(80, r) = r.nextInt(20) + 10.
     MOVE 0 TO WS-I
     CALL "Q5-SHORT-FUSE" USING WS-BASE WS-I WS-A
     MOVE "short fuse at draw 0 is 10" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 19 TO WS-I
     CALL "Q5-SHORT-FUSE" USING WS-BASE WS-I WS-A
     MOVE "short fuse at draw 19 is 29" TO WS-CASE
     MOVE 29 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-5§10A Further readings: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-5-10A.
