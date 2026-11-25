*> Real-data acceptance test (operator report try18: "recipe book often lacks things that it should have"; docs/protocol/27
*> sections 4.6 and 5.9): with the generated data pack (CC_GENERATED_DIR; the cases are skipped, as a pass, when it holds no
*> vanilla-data) a survival player who holds items knows exactly the recipes whose recipe advancement has an inventory_changed
*> criterion that one of the held items satisfies (item ids and "#" item tags, nested tags expanded), plus the tick-unlocked
*> ones. The expected counts were computed independently from the data pack's advancement and tag files (python, every
*> criterion of every data/minecraft/advancement/recipes file) for the cumulative sets of held items below.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGRECIPEBOOK-UNLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CTRECIPE.
 COPY RECBOOK.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-TEXT                PIC X(4096).
 01 WS-K                   BINARY-LONG.
 01 WS-KNOWN-COUNT         BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-STEPS.
    05 WS-STEP-ROW OCCURS 12 TIMES.
       10 WS-STEP-ITEM     PIC X(40).
       10 WS-STEP-EXPECTED BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance bugrecipebook no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     PERFORM FILL-STEPS
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE CN-PLAYER(WS-ALICE) TO WS-PROW
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-PROW, WS-K) PL-SLOT-ITEM(WS-PROW, WS-K)
     END-PERFORM
     CALL "CRAFT-REFRESH-ALL"
     PERFORM COUNT-KNOWN
     MOVE "acceptance bugrecipebook given an empty inventory when the book is counted then only the 2 tick recipes are known"
         TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-KNOWN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 12
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-STEP-ITEM(WS-STEP)) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PROW, WS-STEP)
         MOVE 1 TO PL-SLOT-COUNT(WS-PROW, WS-STEP)
         CALL "CRAFT-REFRESH-ALL"
         CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
         PERFORM COUNT-KNOWN
         MOVE SPACES TO TL-CASE
         STRING "acceptance bugrecipebook given the player now holds " FUNCTION TRIM(WS-STEP-ITEM(WS-STEP))
             " (cumulative) when the book is counted then the data pack's advancements decide" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE WS-STEP-EXPECTED(WS-STEP) TO TL-EXPECTED-N
         MOVE WS-KNOWN-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

 COUNT-KNOWN.
     MOVE 0 TO WS-KNOWN-COUNT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF RB-KNOWN(WS-PROW, WS-K) = 1
             ADD 1 TO WS-KNOWN-COUNT
         END-IF
     END-PERFORM.

 FILL-STEPS.
     MOVE "oak_planks" TO WS-STEP-ITEM(1)
     MOVE 13 TO WS-STEP-EXPECTED(1)
     MOVE "oak_log" TO WS-STEP-ITEM(2)
     MOVE 16 TO WS-STEP-EXPECTED(2)
     MOVE "iron_ingot" TO WS-STEP-ITEM(3)
     MOVE 42 TO WS-STEP-EXPECTED(3)
     MOVE "stone" TO WS-STEP-ITEM(4)
     MOVE 60 TO WS-STEP-EXPECTED(4)
     MOVE "coal" TO WS-STEP-ITEM(5)
     MOVE 62 TO WS-STEP-EXPECTED(5)
     MOVE "string" TO WS-STEP-ITEM(6)
     MOVE 70 TO WS-STEP-EXPECTED(6)
     MOVE "wheat" TO WS-STEP-ITEM(7)
     MOVE 72 TO WS-STEP-EXPECTED(7)
     MOVE "emerald" TO WS-STEP-ITEM(8)
     MOVE 73 TO WS-STEP-EXPECTED(8)
     MOVE "hay_block" TO WS-STEP-ITEM(9)
     MOVE 76 TO WS-STEP-EXPECTED(9)
     MOVE "slime_ball" TO WS-STEP-ITEM(10)
     MOVE 78 TO WS-STEP-EXPECTED(10)
     MOVE "sand" TO WS-STEP-ITEM(11)
     MOVE 96 TO WS-STEP-EXPECTED(11)
     MOVE "cobblestone" TO WS-STEP-ITEM(12)
     MOVE 111 TO WS-STEP-EXPECTED(12).
 END PROGRAM ACC-BUGRECIPEBOOK-UNLOCKS.
 COPY CORETEST.
