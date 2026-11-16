*> Implementation test (lane 002-lane-mobsb; docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.5.1, 44-residual-mob-questions-6-nether.md E3): the barter table
*> (19 rows, total weight 469), the loved items, the currency and the safe armor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-BARTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BARTER.
 01 WS-NAME               PIC X(90).
 01 WS-E                  BINARY-LONG.
 01 WS-O                  BINARY-LONG.
 01 WS-D                  BINARY-LONG.
 01 WS-KEY                PIC X(24).
 01 WS-LO                 BINARY-LONG.
 01 WS-HI                 BINARY-LONG.
 01 WS-MOD                BINARY-LONG.
 01 WS-KEY32              PIC X(32).
 01 WS-GOT                PIC X(24).
 01 WS-DD                 PIC 9(4).
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ONE                BINARY-LONG VALUE 1.
 01 WS-ZERO               BINARY-LONG VALUE 0.
 01 WS-ZERO2              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE 469 TO WS-E
     MOVE BT-TOTAL TO WS-O
     MOVE "acceptance US15 21§5.5.1 the barter weights total 469" TO WS-NAME
     PERFORM CHECK-N
     MOVE 19 TO WS-E
     MOVE BT-COUNT TO WS-O
     MOVE "acceptance US15 21§5.5.1 the barter table has 19 rows" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE "book" TO WS-KEY
     PERFORM CHECK-KEY
     MOVE 1 TO WS-E
     MOVE WS-MOD TO WS-O
     MOVE "acceptance US15 21§5.5.1 the book is enchanted with soul speed" TO WS-NAME
     PERFORM CHECK-N
     MOVE 4 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE "book" TO WS-KEY
     PERFORM CHECK-KEY
     MOVE 5 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE "iron_boots" TO WS-KEY
     PERFORM CHECK-KEY
     MOVE 46 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE "iron_nugget" TO WS-KEY
     PERFORM CHECK-KEY
     MOVE 36 TO WS-E
     MOVE WS-HI TO WS-O
     MOVE "acceptance US15 21§5.5.1 iron nuggets 10 to 36" TO WS-NAME
     PERFORM CHECK-N
     MOVE 468 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE "blackstone" TO WS-KEY
     PERFORM CHECK-KEY
     MOVE 8 TO WS-E
     MOVE WS-LO TO WS-O
     MOVE "acceptance US15 21§5.5.1 blackstone 8 to 16" TO WS-NAME
     PERFORM CHECK-N
     MOVE 469 TO WS-D
     CALL "PIGLIN-BARTER" USING WS-D WS-KEY WS-LO WS-HI WS-MOD
     MOVE SPACES TO WS-KEY
     PERFORM CHECK-KEY
     MOVE "gold_ingot" TO WS-KEY
     CALL "PIGLIN-CURRENCY" USING WS-KEY WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 21§5.5.1 gold ingots are the currency" TO WS-NAME
     PERFORM CHECK-N
     MOVE "gold_nugget" TO WS-KEY
     CALL "PIGLIN-CURRENCY" USING WS-KEY WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 21§5.5.1 nuggets are not currency" TO WS-NAME
     PERFORM CHECK-N
     MOVE "clock" TO WS-KEY
     MOVE WS-KEY TO WS-KEY32
     CALL "PIGLIN-LOVED" USING WS-KEY32 WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 21§5.5.1 a clock is loved" TO WS-NAME
     PERFORM CHECK-N
     MOVE "stone" TO WS-KEY
     MOVE WS-KEY TO WS-KEY32
     CALL "PIGLIN-LOVED" USING WS-KEY32 WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 21§5.5.1 stone is not loved" TO WS-NAME
     PERFORM CHECK-N
     MOVE "golden_boots" TO WS-KEY
     CALL "PIGLIN-SAFE-ARMOR" USING WS-KEY WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 21§5.5.1 golden boots are safe armor" TO WS-NAME
     PERFORM CHECK-N
     MOVE "golden_sword" TO WS-KEY
     CALL "PIGLIN-SAFE-ARMOR" USING WS-KEY WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 21§5.5.1 a golden sword is not armor" TO WS-NAME
     PERFORM CHECK-N
     CALL "PIGLIN-ADMIRE" USING WS-ONE WS-ZERO WS-ZERO2 WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 21§5.5.1 an idle adult accepts the ingot" TO WS-NAME
     PERFORM CHECK-N
     CALL "PIGLIN-ADMIRE" USING WS-ZERO WS-ZERO2 WS-ZERO3 WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 21§5.5.1 a baby does not" TO WS-NAME
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-KEY.
     MOVE SPACES TO TL-CASE
     MOVE WS-D TO WS-DD
     STRING "acceptance US15 21§5.5.1 draw " WS-DD " gives " WS-KEY DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-KEY TO TL-EXPECTED
     CALL "PIGLIN-BARTER" USING WS-D WS-GOT WS-LO WS-HI WS-MOD
     MOVE WS-GOT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-BARTER.
