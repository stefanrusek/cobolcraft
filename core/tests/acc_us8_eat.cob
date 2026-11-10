*> Acceptance test, US8-3 and US8-4 core half (spec US8 scenarios 3 and 4, US8 edge case "eating is
*> interrupted"; tasks T514; standin-content §11.5, §11.6; 09 §3.3 rows 0x43, 0x29 action 6, 0x22):
*> Use Item with a food item held and food below 20 starts eating; after the eating time of 30 ticks
*> one item leaves the held slot, food rises by the item's value up to 20, and the player is sent
*> Set Health, Container Set Slot of the slot and Entity Event 9, which the players who see it are
*> sent too. With food at 24, without a food item held, after Player Action 6 RELEASE_USE_ITEM or a
*> change of the held slot before the eating time, nothing is eaten. Alice (entity 1) and Bobby are
*> survival; Alice holds hotbar slot 0, which the test fills with grazer_flank (item 12, value 3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-EAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 6.
 01 WS-RX                  BINARY-LONG VALUE 0.
 01 WS-RY                  BINARY-LONG VALUE 0.
 01 WS-RZ                  BINARY-LONG VALUE 0.
 01 WS-RFACE               BINARY-LONG VALUE 0.
 01 WS-RSEQ                BINARY-LONG VALUE 0.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HUNGER" USING WS-BOB WS-TEXT
     MOVE 12 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 12 TO PL-FOOD(WS-ROW)

     MOVE "acceptance US8-3 given food 12 and a held grazer_flank when eat has been held for 29 "
         & "ticks then nothing is eaten yet" TO TL-CASE
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 29 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given food 12 and a held grazer_flank when eat is held for the eating "
         & "time (30 ticks) then one item is used, food rises by 3 and Set Health, the slot and "
         & "Entity Event 9 are sent" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE "health 20 food 15 | slot 0=12x2 | event 1 9" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given Alice finished eating then Bobby, who sees her, is sent Entity "
         & "Event 9" TO TL-CASE
     CALL "TEST-DRAIN-HUNGER" USING WS-BOB WS-TEXT
     MOVE "event 1 9" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given food 19 when a grazer_flank (3) is eaten then food rises only "
         & "up to the maximum 20" TO TL-CASE
     MOVE 19 TO PL-FOOD(WS-ROW)
     PERFORM EAT
     MOVE "health 20 food 20 | slot 0=12x1 | event 1 9" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-4 given full food (20) when eat is held then nothing is eaten" TO TL-CASE
     PERFORM EAT
     PERFORM ADD-STATE
     MOVE "food 20 slot 12x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8 edge given food 12 when eat is released (Player Action 6) before the "
         & "eating time then nothing is eaten" TO TL-CASE
     MOVE 12 TO PL-FOOD(WS-ROW)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-RX WS-RY WS-RZ WS-RFACE WS-RSEQ
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "food 12 slot 12x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8 edge given food 12 when the held slot changes before the eating time "
         & "then nothing is eaten" TO TL-CASE
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "food 12 slot 12x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given food 12 and a held item that is not food (pry_bar) when eat is "
         & "held then nothing is eaten" TO TL-CASE
     MOVE 8 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     PERFORM EAT
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     PERFORM ADD-STATE
     MOVE "food 12 slot 12x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given food 12 and the last grazer_flank held when it is eaten then "
         & "the slot becomes empty" TO TL-CASE
     PERFORM EAT
     MOVE "health 20 food 15 | slot 0=0x0 | event 1 9" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Use Item, then 40 ticks (more than the eating time); drains Alice's hunger packets.
 EAT.
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT.

*> Appends Alice's food and slot 0 to the drained text in WS-TEXT ("food <f> slot <item>x<count>").
 ADD-STATE.
     MOVE PL-FOOD(WS-ROW) TO WS-EDIT3
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT2
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " food " FUNCTION TRIM(WS-EDIT3) " slot "
         FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US8-EAT.

 COPY CORETEST.
