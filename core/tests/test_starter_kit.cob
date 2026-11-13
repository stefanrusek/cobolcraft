*> Implementation test of the standard-world starter kit (core/src/players.cob PLAYER-CREATE, STARTER-KIT-CONFIG; docs/design/world-types.md
*> "Starter kit"): a first-time survival player of a standard world gets 1 crafting table, 16 oak logs, 8 oak planks and 8 sticks (the item rows
*> found by key, bare or minecraft: form) in hotbar slots 0 to 3 instead of the stand-in starting items; a returning player is not given them again;
*> the key starter-kit=false turns the kit off; a cobolcraft world keeps the stand-in starting items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STARTER-KIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY CORESTATE.
 COPY CITEMS.
 COPY TESTLIB.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-UUID                PIC X(16) VALUE "0123456789abcdef".
 01 WS-UUID2               PIC X(16) VALUE "fedcba9876543210".
 01 WS-FLAG                BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-PTR                BINARY-LONG.
 01 WS-S                  BINARY-LONG.
 01 WS-IDX                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 5 TO IT-COUNT
     MOVE "stone" TO IT-KEY(1)
     MOVE "crafting_table" TO IT-KEY(2)
     MOVE "minecraft:oak_log" TO IT-KEY(3)
     MOVE "oak_planks" TO IT-KEY(4)
     MOVE "minecraft:stick" TO IT-KEY(5)
     MOVE "T" TO TL-MODE
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE 1 TO WS-FLAG
     CALL "STARTER-KIT-CONFIG" USING WS-FLAG
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PLAYER-CREATE" USING WS-ID WS-NAME WS-NAME-LENGTH WS-UUID WS-ROW
     MOVE "test starter kit a first-time survival player of a standard world gets table, logs, planks, sticks" TO TL-CASE
     MOVE "1/1 2/16 3/8 4/8 0/0" TO TL-EXPECTED
     PERFORM OBSERVE-KIT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     INITIALIZE PL-INVENTORY(WS-ROW)
     CALL "CORE-CONN-CLOSED" USING WS-ID
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PLAYER-CREATE" USING WS-ID WS-NAME WS-NAME-LENGTH WS-UUID WS-ROW
     MOVE "test starter kit a returning player is not given the kit again" TO TL-CASE
     MOVE "0/0 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     PERFORM OBSERVE-KIT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-FLAG
     CALL "STARTER-KIT-CONFIG" USING WS-FLAG
     CALL "STARTER-KIT-GET" USING WS-GOT
     MOVE "test starter kit STARTER-KIT-GET reports the key switched off" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PLAYER-CREATE" USING WS-ID WS-NAME WS-NAME-LENGTH WS-UUID2 WS-ROW
     MOVE "test starter kit starter-kit=false gives a standard world player no kit and no stand-in items" TO TL-CASE
     MOVE "0/0 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     PERFORM OBSERVE-KIT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-FLAG
     CALL "STARTER-KIT-CONFIG" USING WS-FLAG
     CALL "STARTER-KIT-GET" USING WS-GOT
     MOVE "test starter kit STARTER-KIT-GET reports the key switched on" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft" TO CW-WORLD-TYPE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE "0011223344556677" TO WS-UUID2
     CALL "PLAYER-CREATE" USING WS-ID WS-NAME WS-NAME-LENGTH WS-UUID2 WS-ROW
     MOVE "test starter kit a cobolcraft world keeps the stand-in starting items" TO TL-CASE
     MOVE "2/64 3/64 4/64 5/64 11/1" TO TL-EXPECTED
     PERFORM OBSERVE-KIT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 OBSERVE-KIT.
*>   Observed text: item/count of hotbar slots 0 to 3 and of inventory slot 9.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5
         IF WS-S = 5
             MOVE 10 TO WS-IDX
         ELSE
             MOVE WS-S TO WS-IDX
         END-IF
         MOVE PL-SLOT-ITEM(WS-ROW, WS-IDX) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PL-SLOT-COUNT(WS-ROW, WS-IDX) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     .
 END PROGRAM TEST-STARTER-KIT.

 COPY CORETEST.
