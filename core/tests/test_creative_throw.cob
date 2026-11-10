*> Test of the creative cursor throw (CC-0006; core/src/inventory.cob INV-CREATIVE-SET; 05c 0x39 Set Creative Mode Slot with slot -1,
*> the "drop" of the creative inventory screen: a stack carried by the cursor and clicked outside the window; T0397). Alice
*> (entity 1, creative) stands at (20.5, 101, 20.5) on greystone at (20, 100, 20), facing east, so a thrown item appears
*> at (20.50, 102.30, 20.50). The stack of the packet becomes a ground item (a count above the item's maximum stack is
*> lowered to it); a count of 0, an unknown item and a survival player's packet throw nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CREATIVE-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG VALUE 101.0.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE -90.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-PACKET-ID           BINARY-LONG VALUE 57.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test creative throw Set Creative Mode Slot with slot -1 and 5 loam throws 5 loam as a ground "
         & "item at the thrower's eyes" TO TL-CASE
     MOVE -1 TO WS-SLOT
     MOVE 3 TO WS-ITEM
     MOVE 5 TO WS-COUNT
     PERFORM CREATIVE-SET
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "1(2,1@20.50,102.30,20.50) 101(2=3x5) 103(2)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test creative throw a count of 100 is lowered to the item's maximum stack of 64" TO TL-CASE
     MOVE 100 TO WS-COUNT
     PERFORM CREATIVE-SET
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "1(3,1@20.50,102.30,20.50) 101(3=3x64) 103(3)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test creative throw a count of 0, an unknown item and a survival player's packet throw nothing"
         TO TL-CASE
     MOVE 0 TO WS-COUNT
     PERFORM CREATIVE-SET
     MOVE 5 TO WS-COUNT
     MOVE 9999 TO WS-ITEM
     PERFORM CREATIVE-SET
     MOVE 3 TO WS-ITEM
     MOVE 0 TO PL-MODE(WS-ROW)
     PERFORM CREATIVE-SET
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE CW-NEXT-ENTITY-ID TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "next id " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "next id 4" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Feeds Set Creative Mode Slot (0x39) of slot WS-SLOT with WS-COUNT of item WS-ITEM.
 CREATIVE-SET.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-SLOT
     MOVE WS-COUNT TO PB-IS-COUNT
     MOVE WS-ITEM TO PB-IS-ITEM
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     CALL "TEST-FEED-BUFFER" USING WS-ALICE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CREATIVE-THROW.

 COPY CORETEST.
