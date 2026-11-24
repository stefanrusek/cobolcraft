*> Acceptance test, lane try6fix (operator report: food items did nothing on right-click hold; 17 section 4.9, 25 part 1 section 8.2): a standard
*> world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it), whose
*> item rows name the food of an item ("food apple", "food Foods.DRIED_KELP"). Alice (survival) holds food and Use Item starts eating: after
*> the use time (32 ticks, dried kelp 16) one item leaves the stack, food rises by the nutrition and saturation by its saturation (at most to the
*> food level); at food 20 only a food that can always be eaten (golden apple) is eaten.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-EAT-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-IID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FOOD0               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-RX                  BINARY-LONG VALUE 0.
 01 WS-RY                  BINARY-LONG VALUE 0.
 01 WS-RZ                  BINARY-LONG VALUE 0.
 01 WS-RF                  BINARY-LONG VALUE 0.
 01 WS-RS                  BINARY-LONG VALUE 0.
 01 WS-FOOD                PIC 99.
 01 WS-SAT                 PIC 99.9.
 01 WS-COUNT               PIC 9.
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance eat standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Eating" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW

     MOVE "acceptance eat standard: an apple at food 10 gives food 14 and saturation 2.4, one apple less" TO TL-CASE
     MOVE "apple" TO WS-KEY
     MOVE 10 TO WS-FOOD0
     MOVE 33 TO WS-TICKS
     PERFORM EAT
     MOVE "14 02.4 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance eat standard: a half eaten apple (released after 10 ticks) stays" TO TL-CASE
     MOVE 10 TO WS-FOOD0
     MOVE 10 TO WS-TICKS
     PERFORM EAT
     MOVE "10 00.0 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance eat standard: an apple at food 20 is not eaten" TO TL-CASE
     MOVE 20 TO WS-FOOD0
     MOVE 33 TO WS-TICKS
     PERFORM EAT
     MOVE "20 00.0 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance eat standard: a golden apple at food 20 is eaten (always edible), saturation 9.6 up to 20" TO TL-CASE
     MOVE "golden_apple" TO WS-KEY
     MOVE 20 TO WS-FOOD0
     MOVE 33 TO WS-TICKS
     PERFORM EAT
     MOVE "20 09.6 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance eat standard: dried kelp takes 16 ticks, food 1, saturation 0.6" TO TL-CASE
     MOVE "dried_kelp" TO WS-KEY
     MOVE 10 TO WS-FOOD0
     MOVE 17 TO WS-TICKS
     PERFORM EAT
     MOVE "11 00.6 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Holds 3 of the item WS-KEY in slot 0 with food WS-FOOD0 and saturation 0, uses it and lets WS-TICKS ticks pass.
 EAT.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE WS-FOOD0 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "TEST-TICKS" USING WS-TICKS
     IF WS-TICKS < 12
         MOVE 6 TO WS-ACTION
         CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-RX WS-RY WS-RZ WS-RF WS-RS
     END-IF.

 CHECK.
     MOVE PL-FOOD(WS-ROW) TO WS-FOOD
     COMPUTE WS-SAT ROUNDED = PL-SATURATION(WS-ROW)
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-COUNT
     MOVE SPACES TO TL-OBSERVED
     STRING WS-FOOD " " WS-SAT " " WS-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-EAT-STANDARD.

 COPY CORETEST.
