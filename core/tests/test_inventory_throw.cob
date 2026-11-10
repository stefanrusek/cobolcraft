*> Implementation test of the inventory-screen throws (tasks T1085; standin-content §9.1 rows
*> "Inventory-screen throw" and "Inventory screen closed while carrying"; core/src/inventory.cob
*> INV-CLICK, INV-CLOSE; 05c 0x12 Container Click, 0x13 Container Close). Alice (entity 1, survival)
*> stands at (20.5, 101, 20.5) on greystone at (20, 100, 20), facing east (yaw -90, pitch 0), so a
*> thrown item appears at (20.50, 102.30, 20.50) with the motion (0.25, 0.12, 0) and pickup delay 30.
*> Her inventory is emptied first and slot 5 given 5 greystone (item 2). The last cases repeat
*> the throws in creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-THROW.
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
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 19.
 01 WS-S                   BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ER                  BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PATH                PIC X(256).
 01 WS-R1                  PIC -(4)9.9(5).
 01 WS-R2                  PIC -(4)9.9(5).
 01 WS-R3                  PIC -(4)9.9(5).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S) PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 6)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 6)
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test inventory throw survival THROW button 0 on a slot of 5 throws one item (slot "
         & "left with 4) as a Throw" TO TL-CASE
     MOVE 41 TO WS-SLOT
     MOVE 0 TO WS-BUTTON
     MOVE 4 TO WS-TYPE
     PERFORM CLICK
     MOVE 2 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(2,1@20.50,102.30,20.50) 101(2=2x1) 103(2) 20(41=2x4) motion 0.25000,0.12000,"
         & "0.00000 delay 30 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival THROW button 1 throws the whole slot" TO TL-CASE
     MOVE 1 TO WS-BUTTON
     PERFORM CLICK
     MOVE 3 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(3,1@20.50,102.30,20.50) 101(3=2x4) 103(3) 20(41=0x0) motion 0.25000,0.12000,"
         & "0.00000 delay 30 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival THROW on an empty slot does nothing" TO TL-CASE
     MOVE 0 TO WS-BUTTON
     PERFORM CLICK
     PERFORM SHOW-NONE
     MOVE "next id 4 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival PICKUP slot -999 button 0 with a carried stack of 7 "
         & "throws all 7 and empties the cursor" TO TL-CASE
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 7 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE -999 TO WS-SLOT
     MOVE 0 TO WS-TYPE WS-BUTTON
     PERFORM CLICK
     MOVE 4 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(4,1@20.50,102.30,20.50) 101(4=2x7) 103(4) motion 0.25000,0.12000,0.00000 delay "
         & "30 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival PICKUP slot -999 button 1 throws one and leaves 6 "
         & "carried (the empty predicted cursor is resynchronised)" TO TL-CASE
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 7 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 1 TO WS-BUTTON
     PERFORM CLICK
     MOVE 5 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(5,1@20.50,102.30,20.50) 101(5=2x1) 103(5) 18 motion 0.25000,0.12000,0.00000 "
         & "delay 30 cursor 2x6" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival Close Container of another container than 0 changes "
         & "nothing" TO TL-CASE
     MOVE 1 TO WS-CONTAINER
     PERFORM CLOSE-CONTAINER
     PERFORM SHOW-NONE
     MOVE "next id 6 cursor 2x6" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival Close Container (play-c2s-13-container-close.hex) while "
         & "carrying puts the stack back into the inventory" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-13-container-close.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ALICE WS-PATH
     MOVE 0 TO WS-CONTAINER
     PERFORM SHOW-NONE
     MOVE "20(36=2x6) next id 6 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival PICKUP slot -999 with an empty cursor and Close "
         & "Container with an empty cursor do nothing" TO TL-CASE
     MOVE -999 TO WS-SLOT
     MOVE 0 TO WS-BUTTON
     PERFORM CLICK
     PERFORM CLOSE-CONTAINER
     PERFORM SHOW-NONE
     MOVE "next id 6 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw survival Close Container with a full inventory tops up a stack "
         & "of the item and throws the rest" TO TL-CASE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE 3 TO PL-SLOT-ITEM(WS-ROW, WS-S)
         MOVE 64 TO PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 8)
     MOVE 62 TO PL-SLOT-COUNT(WS-ROW, 8)
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 5 TO PL-CARRIED-COUNT(WS-ROW)
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM CLOSE-CONTAINER
     MOVE 6 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(6,1@20.50,102.30,20.50) 101(6=2x3) 103(6) 20(43=2x64) motion 0.25000,0.12000,"
         & "0.00000 delay 30 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw creative THROW button 0 throws one item and button 1 the rest"
         TO TL-CASE
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 39 TO WS-SLOT
     MOVE 4 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     PERFORM CLICK
     MOVE 8 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(7,1@20.50,102.30,20.50) 101(7=3x1) 103(7) 20(39=3x63) 1(8,1@20.50,102.30,20.50) "
         & "101(8=3x63) 103(8) 20(39=0x0) motion 0.25000,0.12000,0.00000 delay 30 cursor 0x0"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw creative PICKUP slot -999 button 0 throws the carried stack"
         TO TL-CASE
     MOVE 4 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 9 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE -999 TO WS-SLOT
     MOVE 0 TO WS-TYPE WS-BUTTON
     PERFORM CLICK
     MOVE 9 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1(9,1@20.50,102.30,20.50) 101(9=4x9) 103(9) motion 0.25000,0.12000,0.00000 delay "
         & "30 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CLICK.
     CALL "TEST-CLICK" USING WS-ALICE WS-SLOT WS-BUTTON WS-TYPE.

*> Feeds Container Close (0x13) of container WS-CONTAINER.
 CLOSE-CONTAINER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-CONTAINER
     CALL "TEST-FEED-BUFFER" USING WS-ALICE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.

*> Drains Alice into WS-TEXT and appends the motion and pickup delay of ground item WS-ENTITY and
*> the cursor.
 DESCRIBE.
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ER
     MOVE 0 TO WS-R1 WS-R2 WS-R3 WS-E1
     IF WS-ER > 0
         COMPUTE WS-R1 ROUNDED = EN-VX(WS-ER)
         COMPUTE WS-R2 ROUNDED = EN-VY(WS-ER)
         COMPUTE WS-R3 ROUNDED = EN-VZ(WS-ER)
         MOVE EN-DELAY(WS-ER) TO WS-E1
     END-IF
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-E2
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " motion " FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) ","
         FUNCTION TRIM(WS-R3) " delay " FUNCTION TRIM(WS-E1) " cursor " FUNCTION TRIM(WS-E2)
         "x" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

*> Drains Alice into WS-TEXT and appends the next entity id and the cursor.
 SHOW-NONE.
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE CW-NEXT-ENTITY-ID TO WS-E1
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-E2
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " next id " FUNCTION TRIM(WS-E1) " cursor "
         FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY-THROW.

 COPY CORETEST.
