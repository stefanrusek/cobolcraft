*> Acceptance test of docs/protocol/16-commands-catalog.md §10.1 `data` over the entity and block holders (permission level 2): get on players, mobs and ground items, the refusal to
*> change a player (commands.data.entity.invalid), merge and modify of the values a mob or ground item takes back (Health, Pos, Motion, Age, PickupDelay, Item.count), block entity data of a
*> chest (Items, id) read and changed through the save and load code, a block with no block entity, a missing entity, and entity and block data as the source of a storage modify.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DATA-HOLDERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY COREAPI.
 COPY MOBS.
 COPY PROTO.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-OBSERVED-N          BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG VALUE 100.
 01 WS-BY                  BINARY-LONG VALUE 64.
 01 WS-BZ                  BINARY-LONG VALUE 100.
 01 WS-BT                  BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:chest".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 15.
 01 WS-BE                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 0.
 01 WS-STACK               BINARY-LONG VALUE 5.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 64.
 01 WS-EDIT                PIC -(9)9.
 01 WS-MOB-SELECTOR        PIC X(80) VALUE "@e[type=cobolcraft:sodgrazer,x=5000,y=70,z=5000,sort=nearest,limit=1]".
 01 WS-ITEM-SELECTOR       PIC X(80) VALUE "@e[x=7000,y=70,z=7000,sort=nearest,limit=1]".
 PROCEDURE DIVISION.
    CALL "TEST-SETTINGS" USING CORE-SETTINGS
    CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
    MOVE "Opal" TO WS-NAME
    MOVE 4 TO WS-NAME-LENGTH
    CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
    CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
    MOVE PL-DIM(1) TO WS-DIM
    MOVE MOB-FIRST-TYPE TO WS-TYPE
    MOVE 5000.5 TO WS-X
    MOVE 70 TO WS-Y
    MOVE 5000.5 TO WS-Z
    CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
    MOVE 7000.5 TO WS-X
    MOVE 7000.5 TO WS-Z
    CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ITEM-ROW
    CALL "BE-CREATE" USING WS-DIM WS-BX WS-BY WS-BZ WS-BT WS-KEY WS-KEY-LENGTH WS-BE
    CALL "BE-SET-ITEM" USING WS-BE WS-SLOT WS-ITEM WS-STACK WS-PATCH WS-MAX
    MOVE "acceptance US13 /data entity: a player's health" TO TL-CASE
    MOVE "data get entity Opal Health" TO WS-LINE
    MOVE "commands.data.entity.get(Health,Opal,1.00,20)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a player's game type" TO TL-CASE
    MOVE "data get entity Opal playerGameType" TO WS-LINE
    MOVE "commands.data.entity.get(playerGameType,Opal,1.00,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: the whole data of a player result is 1" TO TL-CASE
    MOVE "data get entity Opal" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data entity: a player's inventory is a list" TO TL-CASE
    MOVE "data modify storage foo inv set from entity Opal Inventory" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE 1 TO PL-SLOT-ITEM(1, 1)
    MOVE 3 TO PL-SLOT-COUNT(1, 1)
    MOVE "acceptance US13 /data entity: a stack of a player's inventory" TO TL-CASE
    MOVE "data get entity Opal Inventory[{Slot:0b}].count" TO WS-LINE
    MOVE "commands.data.entity.get(Inventory[{Slot:0b}].count,Opal,1.00,3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a player cannot be merged" TO TL-CASE
    MOVE "data merge entity Opal {Health:5f}" TO WS-LINE
    MOVE "commands.data.entity.invalid()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a player cannot be modified" TO TL-CASE
    MOVE "data modify entity Opal Health set value 1f" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a player cannot be removed from" TO TL-CASE
    MOVE "data remove entity Opal Health" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a player's health as the source of a storage" TO TL-CASE
    MOVE "data modify storage foo p set from entity Opal Health" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: the copied health" TO TL-CASE
    MOVE "data get storage foo p" TO WS-LINE
    MOVE "commands.data.storage.get(p,minecraft:foo,1.00,20)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: no such player" TO TL-CASE
    MOVE "data get entity Nobody Health" TO WS-LINE
    MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: no such entity as the source" TO TL-CASE
    MOVE "data modify storage foo q set from entity Nobody Health" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: a mob's health" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data get entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Health" DELIMITED BY SIZE INTO WS-LINE
    MOVE EN-HEALTH(WS-MOB) TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.data.entity.get(Health,cobolcraft:sodgrazer,1.00," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")"
        DELIMITED BY SIZE INTO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: merge changes a mob's health" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data merge entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " {Health:3f}" DELIMITED BY SIZE INTO WS-LINE
    MOVE "commands.data.entity.modified(cobolcraft:sodgrazer)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: the mob has the new health" TO TL-CASE
    MOVE 3 TO WS-EXPECTED-N
    MOVE EN-HEALTH(WS-MOB) TO WS-OBSERVED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: modify moves a mob" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Pos set value [5001.5d,70.0d,5000.5d]"
        DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: the mob is at the new position" TO TL-CASE
    MOVE 5001 TO WS-EXPECTED-N
    COMPUTE WS-OBSERVED-N = FUNCTION INTEGER(EN-X(WS-MOB))
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: a position of one number keeps the other two" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Pos set value [5002.5d]"
        DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: the mob moved on x only" TO TL-CASE
    COMPUTE WS-OBSERVED-N = FUNCTION INTEGER(EN-X(WS-MOB)) * 1000 + FUNCTION INTEGER(EN-Y(WS-MOB))
    MOVE 5002070 TO WS-EXPECTED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: modify rotation and motion" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Rotation set value [90.0f,10.0f]"
        DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Motion set value [0.5d,0.25d,0.125d]"
        DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data entity: yaw, pitch and motion changed" TO TL-CASE
    COMPUTE WS-OBSERVED-N = FUNCTION INTEGER(EN-YAW(WS-MOB)) * 10000 + FUNCTION INTEGER(EN-PITCH(WS-MOB)) * 100
        + FUNCTION INTEGER(EN-VX(WS-MOB) * 4) + FUNCTION INTEGER(EN-VZ(WS-MOB) * 8) - 1
    MOVE 901002 TO WS-EXPECTED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: a health that is no number is ignored" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Health set value " DELIMITED BY SIZE
        '"x"' DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE 3 TO WS-EXPECTED-N
    MOVE EN-HEALTH(WS-MOB) TO WS-OBSERVED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: a ground item's count" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data get entity " DELIMITED BY SIZE WS-ITEM-SELECTOR DELIMITED BY SPACE " Item.count" DELIMITED BY SIZE INTO WS-LINE
    CALL "TA-CHECK-ITEM" USING WS-ID-OPAL TL-CASE WS-LINE
    MOVE "acceptance US13 /data entity: modify a ground item's count, age and pickup delay" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data modify entity " DELIMITED BY SIZE WS-ITEM-SELECTOR DELIMITED BY SPACE " Item.count set value 7" DELIMITED BY SIZE
        INTO WS-LINE
    CALL "TA-CHECK-ITEM" USING WS-ID-OPAL TL-CASE WS-LINE
    MOVE SPACES TO WS-LINE
    STRING "data merge entity " DELIMITED BY SIZE WS-ITEM-SELECTOR DELIMITED BY SPACE " {Age:99,PickupDelay:5s}" DELIMITED BY SIZE
        INTO WS-LINE
    CALL "TA-CHECK-ITEM" USING WS-ID-OPAL TL-CASE WS-LINE
    MOVE "acceptance US13 /data entity: the ground item took the values back" TO TL-CASE
    COMPUTE WS-OBSERVED-N = EN-ITEM-COUNT(WS-ITEM-ROW) * 10000 + EN-AGE(WS-ITEM-ROW) * 10 + EN-DELAY(WS-ITEM-ROW)
    COMPUTE WS-EXPECTED-N = 7 * 10000 + 99 * 10 + 5
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data entity: remove on a mob removes the key but nothing is taken back" TO TL-CASE
    MOVE SPACES TO WS-LINE
    STRING "data remove entity " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " Health" DELIMITED BY SIZE INTO WS-LINE
    MOVE "commands.data.entity.modified(cobolcraft:sodgrazer)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED

    MOVE "acceptance US13 /data block: the id of a chest" TO TL-CASE
    MOVE "data get block 100 64 100 id" TO WS-LINE
    MOVE "commands.data.block.get(id,100,64,100,1.00,15)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: the count of a stack" TO TL-CASE
    MOVE "data get block 100 64 100 Items[0].count" TO WS-LINE
    MOVE "commands.data.block.get(Items[0].count,100,64,100,1.00,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: the whole data result is 1" TO TL-CASE
    MOVE "data get block 100 64 100" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data block: modify the count" TO TL-CASE
    MOVE "data modify block 100 64 100 Items[0].count set value 9" TO WS-LINE
    MOVE "commands.data.block.modified(100,64,100)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: the chest holds the new count" TO TL-CASE
    MOVE 9 TO WS-EXPECTED-N
    MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBSERVED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data block: the count of a stack as the source of a storage" TO TL-CASE
    MOVE "data modify storage foo c set from block 100 64 100 Items[0].count" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: remove the stack" TO TL-CASE
    MOVE "data remove block 100 64 100 Items[0]" TO WS-LINE
    MOVE "commands.data.block.modified(100,64,100)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: the chest is empty" TO TL-CASE
    MOVE 0 TO WS-EXPECTED-N
    MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBSERVED-N
    CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
    MOVE "acceptance US13 /data block: a block with no block entity" TO TL-CASE
    MOVE "data get block 101 64 100" TO WS-LINE
    MOVE "commands.data.block.invalid()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data block: a block with no block entity as the source" TO TL-CASE
    MOVE "data modify storage foo d set from block 101 64 100" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-DATA-HOLDERS.

*> TA-CHECK-ITEM USING connection id, case, line: the player runs the line and its result is 1 or more messages (the text is dropped); the `modified` or `get` message is not compared (the
*> entity type key of a ground item is a content value this test does not pin).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TA-CHECK-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEAD                PIC X(4096).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CASE                 PIC X(240).
 01 L-LINE                 PIC X(768).
 PROCEDURE DIVISION USING L-ID L-CASE L-LINE.
     CALL "TEST-RUN" USING L-ID L-LINE WS-TEXT
     MOVE SPACES TO WS-HEAD
     MOVE WS-TEXT(1:20) TO WS-HEAD
     IF WS-TEXT(1:13) = "commands.data"
         MOVE "commands.data" TO WS-HEAD
     END-IF
     MOVE "commands.data" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING L-CASE WS-EXPECTED WS-HEAD
     GOBACK.
 END PROGRAM TA-CHECK-ITEM.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
