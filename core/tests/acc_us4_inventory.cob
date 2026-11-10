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
 01 WS-SLOT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CHANGED-PRESENT     BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
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

     MOVE "acceptance US4-6 given the starting items when hotbar slot 0 (menu slot 36) is picked up "
         & "(Container Click, state id 1) then the cursor holds 64 greystone, the slot is empty and "
         & "Container Set Slot echoes slot 36 with state id 2" TO TL-CASE
     MOVE 36 TO WS-SLOT
     MOVE 1 TO WS-STATE
     MOVE 0 TO WS-CHANGED-PRESENT
     PERFORM BUILD-CLICK
     CALL "TEST-FEED-BUFFER" USING WS-ALICE PB-BUFFER
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-SLOTS
     MOVE "20(2,36=0x0) cursor 2x64 9:11x1 37:3x64 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 "
         & "44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-6 given greystone on the cursor when it is put down on the empty slot "
         & "12 (state id 2) then slot 12 holds it, the cursor is empty and slot 12 is echoed"
         TO TL-CASE
     MOVE 12 TO WS-SLOT
     MOVE 2 TO WS-STATE
     MOVE 1 TO WS-CHANGED-PRESENT
     PERFORM BUILD-CLICK
     CALL "TEST-FEED-BUFFER" USING WS-ALICE PB-BUFFER
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-SLOTS
     MOVE "20(3,12=2x64) cursor 0x0 9:11x1 12:2x64 37:3x64 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 "
         & "43:9x64 44:10x1" TO TL-EXPECTED
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

*> Builds a Container Click of container 0 (PICKUP, left button) on slot WS-SLOT with state id WS-STATE, the predicted
*> changed slot WS-SLOT (greystone 64 when WS-CHANGED-PRESENT is 1, else empty) and the predicted carried
*> stack (greystone 64 when the changed slot is empty, else none).
 BUILD-CLICK.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 18 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STATE
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-SLOT
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-SLOT
     IF WS-CHANGED-PRESENT = 1
         PERFORM PUT-GREYSTONE
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
         PERFORM PUT-GREYSTONE
     END-IF.

 PUT-GREYSTONE.
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     MOVE 2 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 64 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM.

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
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
         IF WS-COUNT > 0
             MOVE WS-S TO WS-EDIT
             MOVE WS-ITEM TO WS-EDIT2
             MOVE WS-COUNT TO WS-EDIT3
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
