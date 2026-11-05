*> Acceptance test, US4-6 core half (spec US4 scenario 6; tasks T452; data-model §4; 09 §3.2 rows
*> 0x36, 0x12, 0x39, 0x14): the player chooses the held hotbar slot (Set Carried Item) and moves
*> items between slots (Container Click); the server's slots and held slot match and each changed
*> slot is echoed with Container Set Slot. A creative player sets a slot with Set Creative Mode Slot;
*> a survival player cannot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-INVENTORY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

     MOVE "acceptance US4-6 given an inventory when the held slot is changed to 3 (Set Carried "
         & "Item) then the server's held slot is 3" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-36-set-carried-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ALICE WS-PATH
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-HELD(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US4-6 given the starting items when slot 0 is picked up (Container Click, "
         & "state id 1) then the cursor holds 64 greystone, slot 0 is empty and Container Set "
         & "Slot echoes slot 0 with state id 2" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-12-container-click.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ALICE WS-PATH
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-SLOTS
     MOVE "20(2,0=0x0) cursor 2x64 1:3x64 2:4x64 3:5x64 4:6x64 5:7x64 6:8x64 7:9x64 8:10x1 "
         & "9:11x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-6 given greystone on the cursor when it is put down on the empty slot "
         & "12 (state id 2) then slot 12 holds it, the cursor is empty and slot 12 is echoed"
         TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 18 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 2 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 12 TO WS-NUM
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 12 TO WS-NUM
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     MOVE 2 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 64 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     CALL "TEST-FEED-BUFFER" USING WS-ALICE PB-BUFFER
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-SLOTS
     MOVE "20(3,12=2x64) cursor 0x0 1:3x64 2:4x64 3:5x64 4:6x64 5:7x64 6:8x64 7:9x64 8:10x1 "
         & "9:11x1 12:2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-6 given a survival player when Set Creative Mode Slot arrives then "
         & "the slot is unchanged" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-39-set-creative-mode-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ALICE WS-PATH
     MOVE "N" TO TL-MODE
     MOVE 1101 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 10) * 100 + PL-SLOT-COUNT(WS-ROW, 10)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO CS-DEFAULT-MODE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "acceptance US4-6 given a creative player when Set Creative Mode Slot sets slot 9 to "
         & "64 lucite then the server's slot 9 holds 64 lucite and nothing is echoed" TO TL-CASE
     CALL "TEST-FEED" USING WS-BOB WS-PATH
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     PERFORM ADD-SLOTS
     MOVE "cursor 0x0 9:7x64" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Appends " cursor <item>x<count>" and " <slot>:<item>x<count>" for each non-empty slot of WS-ROW
*> to WS-TEXT.
 ADD-SLOTS.
     MOVE 1 TO WS-PTR
     INSPECT WS-TEXT TALLYING WS-PTR FOR CHARACTERS BEFORE INITIAL "   "
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-EDIT
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-EDIT2
     STRING "cursor " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO WS-TEXT POINTER WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT-COUNT(WS-ROW, WS-S) > 0
             COMPUTE WS-EDIT = WS-S - 1
             MOVE PL-SLOT-ITEM(WS-ROW, WS-S) TO WS-EDIT2
             MOVE PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-EDIT3
             STRING " " FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US4-INVENTORY.

 COPY CORETEST.
