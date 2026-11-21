*> Test of 31 section 11 (EnderChestBlockEntity; T0861): no own NBT (only the base keys), the open conditions of the block
*> (an ender chest entity at the position, no conductor above), the open hooks (sound, block event 1 with the new count), and
*> stillValid with an active chest.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 COPY BEFX.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ENDER               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-OUT                 PIC X(8192).
 01 WS-RANGE               BINARY-LONG VALUE 4500.
 01 WS-SPEC                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "minecraft:ender_chest" TO WS-KEY
     MOVE 21 TO WS-LEN
     MOVE 3 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-ENDER

     MOVE "acceptance US12 31-1§11 ender chest: its saved compound holds only components, id, x, y, z" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-ENDER WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     MOVE SPACES TO WS-TEXT
     MOVE WS-OUT(1:WS-LEN) TO WS-TEXT
     MOVE "{components:{},id:minecraft:ender_chest,x:5,y:70,z:5}" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§11 ender chest: opens only with an ender chest entity at the position and no redstone conductor above" TO TL-CASE
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE-ENDER-OPEN" USING WS-A WS-B WS-RES
     MOVE WS-RES TO WS-EDIT
     MOVE 0 TO WS-A
     CALL "BE-ENDER-OPEN" USING WS-A WS-B WS-RES
     MOVE WS-RES TO WS-EDIT2
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE-ENDER-OPEN" USING WS-A WS-B WS-RES
     MOVE WS-RES TO WS-EDIT3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) FUNCTION TRIM(WS-EDIT2) FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§11 ender chest: open hooks: sound and block event 1 with the new count, no neighbour update" TO TL-CASE
     CALL "BE-OPEN-INC" USING WS-ENDER WS-RANGE WS-SPEC BE-FX
     MOVE FX-SOUND TO WS-EDIT
     MOVE FX-BLOCK-EVENT TO WS-EDIT2
     MOVE FX-NEIGHBOURS TO WS-EDIT3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 1 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§11 ender chest: stillValid needs the active chest to be valid when one exists, else the simple container's rule" TO TL-CASE
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE-ENDER-VALID" USING WS-A WS-B WS-C WS-RES
     MOVE WS-RES TO WS-EDIT
     MOVE 1 TO WS-B
     CALL "BE-ENDER-VALID" USING WS-A WS-B WS-C WS-RES
     MOVE WS-RES TO WS-EDIT2
     MOVE 0 TO WS-A
     CALL "BE-ENDER-VALID" USING WS-A WS-B WS-C WS-RES
     MOVE WS-RES TO WS-EDIT3
     MOVE 0 TO WS-C
     CALL "BE-ENDER-VALID" USING WS-A WS-B WS-C WS-RES
     MOVE WS-RES TO WS-EDIT4
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) FUNCTION TRIM(WS-EDIT2) FUNCTION TRIM(WS-EDIT3) FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0110" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-11.

 COPY CORETEST.
