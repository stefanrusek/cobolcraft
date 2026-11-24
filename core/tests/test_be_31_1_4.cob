*> Test of 31 section 4 (Common NBT conventions; T0847): Items is always written for chest and barrel (an empty list when empty) and
*> only when non-empty for the shulker box; the ender chest has no own keys; LootTable replaces Items and the seed is written only when
*> non-zero; lock and CustomName only when set; on load a present LootTable hides Items and invalid Slot values are skipped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-4.
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
 COPY COREAPI.
     COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-PTR                 BINARY-LONG.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-FORM                BINARY-LONG VALUE 2.
 01 WS-OUT                 PIC X(8192).
 01 WS-CHEST               BINARY-LONG.
 01 WS-SHULKER             BINARY-LONG.
 01 WS-BARREL              BINARY-LONG.
 01 WS-ENDER               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-SLOT                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT2               PIC X(8192).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "minecraft:chest" TO WS-KEY
     MOVE 15 TO WS-LEN
     MOVE 1 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-CHEST
     ADD 1 TO WS-X
     MOVE "minecraft:barrel" TO WS-KEY
     MOVE 16 TO WS-LEN
     MOVE 26 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-BARREL
     ADD 1 TO WS-X
     MOVE "minecraft:shulker_box" TO WS-KEY
     MOVE 21 TO WS-LEN
     MOVE 24 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-SHULKER
     ADD 1 TO WS-X
     MOVE "minecraft:ender_chest" TO WS-KEY
     MOVE 21 TO WS-LEN
     MOVE 3 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-ENDER

     MOVE "acceptance US12 31-1§4 NBT: Items is written for an empty chest and barrel, omitted for an empty shulker box, absent for the ender chest" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-CHEST TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE WS-BARREL TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE WS-SHULKER TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE WS-ENDER TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE "{Items:[]} {Items:[]} {} {}" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§4 NBT: LootTable replaces Items, the seed is written only when non-zero" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE "minecraft:chests/simple_dungeon" TO BE-LOOT(WS-CHEST)
     MOVE 31 TO BE-LOOT-LENGTH(WS-CHEST)
     MOVE WS-CHEST TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE 12345 TO BE-SEED(WS-CHEST)
     PERFORM SAVE-RENDER
     MOVE '{LootTable:minecraft:chests/simple_dungeon} {LootTable:minecraft:chests/simple_dungeon,LootTableSeed:12345}' TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§4 NBT: lock and CustomName are written only when set, before Items" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE SPACES TO BE-LOOT(WS-CHEST)
     MOVE 0 TO BE-LOOT-LENGTH(WS-CHEST) BE-SEED(WS-CHEST)
     MOVE "minecraft:tripwire_hook" TO BE-LOCK(WS-CHEST)
     MOVE 23 TO BE-LOCK-LENGTH(WS-CHEST)
     MOVE "Boxy" TO BE-NAME(WS-CHEST)
     MOVE 4 TO BE-NAME-LENGTH(WS-CHEST)
     PERFORM SAVE-RENDER
     MOVE '{lock:{items:minecraft:tripwire_hook},CustomName:Boxy,Items:[]}' TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§4 NBT: a non-empty slot is written as an element with Slot, id and count; the shulker box then writes Items" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 1 TO BE-SLOT-ITEM(WS-SHULKER, 3)
     MOVE 10 TO BE-SLOT-COUNT(WS-SHULKER, 3)
     MOVE WS-SHULKER TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE SPACES TO WS-ITEM-KEY
     MOVE IT-KEY(2) TO WS-ITEM-KEY
     MOVE SPACES TO WS-TEXT2
     STRING "{Items:[{Slot:2,id:" FUNCTION TRIM(WS-ITEM-KEY) ",count:10}]}" DELIMITED BY SIZE INTO WS-TEXT2
     MOVE WS-TEXT2 TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§4 NBT: loading a compound with LootTable ignores Items and keeps the slots empty" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "LootTable" TO WS-NAME
     MOVE 9 TO WS-LEN
     MOVE "minecraft:chests/x" TO WS-ITEM-KEY
     MOVE 18 TO WS-I
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NAME WS-LEN WS-ITEM-KEY WS-I
     PERFORM WRITE-ITEMS
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE WS-BARREL TO WS-IDX
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE BE-SLOT-COUNT(WS-BARREL, 3) TO WS-EDIT
     MOVE BE-LOOT(WS-BARREL) TO WS-OUT
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-OUT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0 minecraft:chests/x" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§4 NBT: loading Items places valid slots and skips Slot values outside 0 to size - 1" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM WRITE-ITEMS
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE WS-CHEST TO WS-IDX
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE BE-SLOT-COUNT(WS-CHEST, 3) TO WS-EDIT
     MOVE BE-SLOT-COUNT(WS-CHEST, 27) TO WS-EDIT2
     MOVE BE-LOOT-LENGTH(WS-CHEST) TO WS-EDIT3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "7 0 0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR.

*> An Items list of two elements: slot 2 (count 7) and slot 30 (count 9, outside a 27-slot container).
 WRITE-ITEMS.
     MOVE "Items" TO WS-NAME
     MOVE 5 TO WS-LEN
     MOVE 2 TO WS-I
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NAME WS-LEN WS-TYPE10 WS-I
     MOVE 2 TO WS-SLOT
     PERFORM WRITE-ELEMENT
     MOVE 30 TO WS-SLOT
     PERFORM WRITE-ELEMENT.

 WRITE-ELEMENT.
     MOVE -1 TO WS-I
     MOVE "Slot" TO WS-NAME
     MOVE 4 TO WS-LEN
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NAME WS-LEN WS-SLOT
     MOVE 1 TO WS-ITEM
     IF WS-SLOT = 2
         MOVE 7 TO WS-COUNT
     ELSE
         MOVE 9 TO WS-COUNT
     END-IF
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-COUNT WS-KP
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-4.

 COPY CORETEST.
