*> Acceptance test, US12 containers, the refusals and edges of the play path (docs/protocol/31-block-entities-1 sections 8 to 13, 40-menus-1
*> sections 3.4, 3.8, 4.4, 7, 8; coverage of core/src/menu-container.cob and the placement of core/src/be-world.cob): placement faces (left
*> neighbour, barrel pitch, shulker side face), a conductor above a chest, a locked chest and its key in hand, a menu replaced by another,
*> a spectator, a removed or missing entity, a full ender table, shift-click on an empty slot, PICKUP_ALL in a chest.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-CONTAINERS-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-CHEST               BINARY-LONG.
 01 WS-BARREL              BINARY-LONG.
 01 WS-ENDER               BINARY-LONG.
 01 WS-SHULKER             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-MENU-SLOT           BINARY-LONG.
 01 WS-CONTAINER-SLOT      BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-CHEST
     MOVE "minecraft:barrel" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BARREL
     MOVE "minecraft:ender_chest" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ENDER
     MOVE "minecraft:shulker_box" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHULKER
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STONE
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 containers edges given a single chest when another is placed on its west side facing the same way then "
         & "the new chest is the left half and the old one the right half" TO TL-CASE
     PERFORM PREPARE-GROUND
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = WS-BX + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE2
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     COMPUTE WS-E2 = WS-STATE2 - CB-FIRST-STATE(WS-ID + 1)
     MOVE SPACES TO WS-TEXT
     STRING "new " FUNCTION TRIM(WS-E1) " old " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "new 3 old 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a barrel placed with the pitch looking down (60) then it faces up, looking up "
         & "(-60) then down, and a shulker box placed on a side face faces that way" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BARREL TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 60 TO PL-PITCH(WS-ROW)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     MOVE -60 TO PL-PITCH(WS-ROW)
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-FLOOR
     MOVE 0 TO PL-PITCH(WS-ROW)
     MOVE "minecraft:barrel" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = WS-BX + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE2
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     COMPUTE WS-E2 = WS-STATE2 - CB-FIRST-STATE(WS-ID + 1)
     MOVE WS-SHULKER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     COMPUTE WS-X = WS-BX + 2
     COMPUTE WS-Y = WS-BY
     MOVE WS-BZ TO WS-Z
     MOVE 5 TO WS-FACE
     COMPUTE WS-S = WS-X - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-S WS-Y WS-Z WS-STONE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-S WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "minecraft:shulker_box" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-E3 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     MOVE SPACES TO WS-TEXT
     STRING "up " FUNCTION TRIM(WS-E1) " down " FUNCTION TRIM(WS-E2) " shulker " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "up 9 down 11 shulker 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a chest with a block above it that conducts (greystone) when Use Item On is sent "
         & "then the menu does not open and the chest has no opener" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     COMPUTE WS-Y = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-STONE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " openers " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0 openers 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a double chest with a conductor above one half then neither half opens" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-FLOOR
     COMPUTE WS-Y = WS-BY + 1
     COMPUTE WS-X = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a locked chest when Alice has another item in hand then it stays shut, when she "
         & "holds the key item it opens" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE "minecraft:barrel" TO BE-LOCK(WS-BE)
     MOVE 16 TO BE-LOCK-LENGTH(WS-BE)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE WS-BARREL TO PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-BLOCK
     PERFORM FLAG-WINDOW
     MOVE WS-S TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "shut " FUNCTION TRIM(WS-E1) " key " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "shut 0 key 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given an open chest when a second chest is opened then the first menu is closed (its opener "
         & "count drops) and the second has one" TO TL-CASE
     COMPUTE WS-X = WS-BX + 2
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-FLOOR
     MOVE "Loot" TO BE-NAME(WS-BE)
     MOVE 4 TO BE-NAME-LENGTH(WS-BE)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     COMPUTE WS-X = WS-BX + 2
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE2
     PERFORM USE-BLOCK
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E1
     MOVE BE-OPEN-COUNT(WS-BE2) TO WS-E2
     PERFORM FLAG-WINDOW
     MOVE WS-S TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "first " FUNCTION TRIM(WS-E1) " second " FUNCTION TRIM(WS-E2) " window " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "first 0 second 1 window 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given an open chest with stacks of the same item in slots 0 and 3 when PICKUP_ALL "
         & "is used on the empty slot 1 with the item on the cursor then the cursor gathers them" TO TL-CASE
     MOVE 2 TO WS-ITEM
     MOVE 5 TO WS-COUNT
     MOVE 0 TO WS-S
     CALL "MENU-SET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE 3 TO WS-S
     MOVE 7 TO WS-COUNT
     CALL "MENU-SET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO PL-CARRIED-VAR(WS-ROW)
     MOVE 1 TO WS-S
     MOVE 0 TO WS-BUTTON
     MOVE 6 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE 0 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-COUNT TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " slot0 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 13 slot0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given an open chest when an empty slot is shift-clicked then nothing moves, and the menu "
         & "numbers of the player's inventory slots 9, 35, 0 and 8 are 27, 53, 54 and 62 for a 27-slot container" TO TL-CASE
     MOVE 5 TO WS-S
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 9 TO WS-CONTAINER-SLOT
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-CONTAINER-SLOT WS-MENU-SLOT
     MOVE WS-MENU-SLOT TO WS-E1
     MOVE 35 TO WS-CONTAINER-SLOT
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-CONTAINER-SLOT WS-MENU-SLOT
     MOVE WS-MENU-SLOT TO WS-E2
     MOVE 0 TO WS-CONTAINER-SLOT
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-CONTAINER-SLOT WS-MENU-SLOT
     MOVE WS-MENU-SLOT TO WS-E3
     MOVE 8 TO WS-CONTAINER-SLOT
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-CONTAINER-SLOT WS-MENU-SLOT
     MOVE WS-MENU-SLOT TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "27 53 54 62" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

     MOVE "acceptance US12 containers edges given a spectator when a chest is opened then the menu opens and the chest counts no "
         & "opener, and closing it counts none down" TO TL-CASE
     MOVE 3 TO PL-MODE(WS-ROW)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     PERFORM USE-BLOCK
     PERFORM FLAG-WINDOW
     MOVE WS-S TO WS-E1
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E2
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E3
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " openers " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 1 openers 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a chest block whose entity is missing when it is used then nothing opens, and an "
         & "open chest that is removed closes at the next tick" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 0 TO BE-USED(WS-BE)
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     COMPUTE WS-X = WS-BX + 2
     PERFORM USE-BLOCK
     PERFORM FLAG-WINDOW
     MOVE WS-S TO WS-E2
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE
     MOVE 2 TO WS-OFFSET
     CALL "TEST-TICKS" USING WS-OFFSET
     MOVE MN-WINDOW(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "missing " FUNCTION TRIM(WS-E1) " open " FUNCTION TRIM(WS-E2) " after removal " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "missing 0 open 1 after removal 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given every ender chest slot of the table taken when Alice opens an ender chest then it "
         & "does not open" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-ENDER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ENDER-MAX
         MOVE 1 TO ENDER-USED(WS-I)
         MOVE "ZZZZZZZZZZZZZZZZ" TO ENDER-UUID(WS-I)
     END-PERFORM
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers edges given a block that is no container when MENU-CONT-OPEN is asked to open it then it does "
         & "not open" TO TL-CASE
     COMPUTE WS-Y = WS-BY - 1
     MOVE WS-BX TO WS-X
     MOVE 5 TO WS-OFFSET
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-Y WS-BZ WS-OFFSET
     MOVE WS-OFFSET TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "opened " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "opened 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 FLAG-WINDOW.
     MOVE 0 TO WS-S
     IF MN-WINDOW(WS-ROW) > 0
         MOVE 1 TO WS-S
     END-IF.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE
         MOVE 0 TO WS-STATE2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-S = WS-BY + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-BZ WS-STATE2
         END-PERFORM
     END-PERFORM.

 USE-FLOOR.
     ADD 1 TO WS-SEQ
     COMPUTE WS-Y = WS-BY - 1
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-CONTAINERS-EDGES.

 COPY CORETEST.
 COPY BETEST.
