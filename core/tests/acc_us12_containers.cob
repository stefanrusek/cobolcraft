*> Acceptance test, US12 containers through the real play path (docs/protocol/31-block-entities-1 sections 5 to 13, 40-menus-1 sections 3,
*> 4, 7, 8; tasks T0841 to T1008 wired): a survival player places a chest (Use Item On with the held chest item), opens it (Block
*> Event, Open Screen, Container Set Content), puts items in and takes them out with Container Click (a stack with a component patch keeps
*> it), shift-clicks, closes (Block Event 0) and reopens it with the contents there; a second chest beside it merges into a double chest
*> (54 slots, either half opens it) and breaking one half leaves a single chest again; the world saved and reloaded still holds the
*> contents; an ender chest holds the player's own items at every ender chest and another player sees his own; a barrel shows its
*> open state while open; a shulker box refuses shulker boxes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-CONTAINERS.
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
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
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
 01 WS-VAR                 BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-NAMETEXT            PIC X(64).
 01 WS-NAMELEN             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-BARREL              BINARY-LONG.
 01 WS-ENDER               BINARY-LONG.
 01 WS-SHULKER             BINARY-LONG.
 01 WS-RED                 BINARY-LONG.
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
     MOVE "minecraft:red_shulker_box" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-RED
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 containers given a held chest when Use Item On is sent on the top face of the floor then a chest "
         & "(default state, facing north) is placed above it with a chest block entity" TO TL-CASE
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     MOVE WS-BZ TO WS-Z
     PERFORM USE-FLOOR
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE WS-STATE TO WS-E1
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-E2
     MOVE BE-TYPE(WS-BE) TO WS-E3
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E4
     MOVE SPACES TO WS-TEXT
     IF WS-STATE = CB-DEFAULT-STATE(WS-ID + 1) AND WS-BE > 0
         STRING "placed type " FUNCTION TRIM(WS-E3) " left " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     ELSE
         STRING "not placed " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     MOVE "placed type 1 left 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a placed chest when Use Item On is sent on it then Block Event, Open Screen and "
         & "Container Set Content follow, window 1 is generic_9x3 (type 2) over 27 slots and the chest has one opener" TO TL-CASE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE MN-TYPE(WS-ROW) TO WS-E2
     MOVE MN-CSIZE(WS-ROW) TO WS-E3
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E4
     MOVE "7" TO WS-KEY
     PERFORM HAS-ID
     MOVE WS-TALLY TO WS-E5
     MOVE "60" TO WS-KEY
     PERFORM HAS-ID
     MOVE WS-TALLY TO WS-E6
     MOVE "119" TO WS-KEY
     PERFORM HAS-ID
     MOVE WS-TALLY TO WS-E7
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " type " FUNCTION TRIM(WS-E2) " size " FUNCTION TRIM(WS-E3) " openers "
         FUNCTION TRIM(WS-E4) " event " FUNCTION TRIM(WS-E5) " screen " FUNCTION TRIM(WS-E6) " sound " FUNCTION TRIM(WS-E7)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 1 type 2 size 27 openers 1 event 1 screen 1 sound 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given an open chest when a named stack of 10 is picked up from the hotbar and put on chest "
         & "slot 4 then the chest slot holds it with the name patch and the cursor is empty" TO TL-CASE
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 10 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO WS-HANDLE
     MOVE "Gold" TO WS-NAMETEXT
     MOVE 4 TO WS-NAMELEN
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAMETEXT WS-NAMELEN
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 58 TO WS-S
     MOVE 0 TO WS-BUTTON
     MOVE 0 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 4 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-ITEM(WS-BE, 5) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E2
     MOVE BE-SLOT-VAR(WS-BE, 5) TO WS-HANDLE
     CALL "SP-GET-NAME" USING WS-HANDLE WS-NAMETEXT WS-NAMELEN
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " WS-NAMETEXT(1:WS-NAMELEN) " cursor " FUNCTION TRIM(WS-E3)
         " hotbar " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "2x10 Gold cursor 0 hotbar 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a chest slot holding a stack when it is clicked and the cursor put on hotbar slot 2 "
         & "then the player slot holds the stack and the chest slot is empty" TO TL-CASE
     MOVE 4 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 59 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-SLOT-ITEM(WS-ROW, 6) TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROW, 6) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE PL-SLOT-VAR(WS-ROW, 6) TO WS-HANDLE
     CALL "SP-GET-NAME" USING WS-HANDLE WS-NAMETEXT WS-NAMELEN
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " WS-NAMETEXT(1:WS-NAMELEN) " chest " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "2x10 Gold chest 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given an open chest when the hotbar stack is shift-clicked then it goes to the first chest "
         & "slot, and shift-clicking that chest slot sends it back to the end of the hotbar" TO TL-CASE
     MOVE 59 TO WS-S
     MOVE 1 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-ITEM(WS-BE, 1) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E2
     MOVE PL-SLOT-COUNT(WS-ROW, 6) TO WS-E3
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E4
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = 2
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "chest " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " hotbar " FUNCTION TRIM(WS-E3) " back " FUNCTION TRIM(WS-E4)
         " inventory " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "chest 2x10 hotbar 0 back 0 inventory 10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a chest with an item at slot 10 when the menu is closed then Block Event 0 is sent, the "
         & "window is 0, the opener count 0 and the item stays" TO TL-CASE
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 11)
     MOVE 33 TO BE-SLOT-COUNT(WS-BE, 11)
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     MOVE "7" TO WS-KEY
     PERFORM HAS-ID
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 11) TO WS-E3
     MOVE MN-CSIZE(WS-ROW) TO WS-E4
     MOVE WS-TALLY TO WS-E5
     MOVE "119" TO WS-KEY
     PERFORM HAS-ID
     MOVE WS-TALLY TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " openers " FUNCTION TRIM(WS-E2) " item " FUNCTION TRIM(WS-E3) " size "
         FUNCTION TRIM(WS-E4) " event " FUNCTION TRIM(WS-E5) " sound " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0 openers 0 item 33 size 0 event 1 sound 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a closed chest when it is opened again then its slot 10 shows the stack in the menu" TO TL-CASE
     PERFORM USE-BLOCK
     MOVE 10 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-ITEM TO WS-E1
     MOVE WS-COUNT TO WS-E2
     MOVE MN-WINDOW(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " window " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "2x33 window 2" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 containers given a chest when a second chest is placed beside it facing the same way then they merge: "
         & "the first becomes left, the new one right" TO TL-CASE
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     COMPUTE WS-X = WS-BX + 1
     MOVE WS-BZ TO WS-Z
     PERFORM USE-FLOOR
     COMPUTE WS-X = WS-BX + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE2
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     COMPUTE WS-E2 = WS-STATE2 - CB-FIRST-STATE(WS-ID + 1)
     MOVE SPACES TO WS-TEXT
     STRING "A " FUNCTION TRIM(WS-E1) " B " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "A 3 B 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a double chest when the right half is opened then the menu has 54 slots (generic_9x6, "
         & "type 5), its slots 27 to 53 are the left half's and both halves count one opener" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE2
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE 2 TO WS-ITEM
     MOVE 3 TO WS-COUNT
     MOVE 30 TO WS-S
     CALL "MENU-SET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE MN-TYPE(WS-ROW) TO WS-E2
     MOVE MN-CSIZE(WS-ROW) TO WS-E3
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E4
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E5
     MOVE BE-OPEN-COUNT(WS-BE2) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E2) " size " FUNCTION TRIM(WS-E3) " left-slot3 " FUNCTION TRIM(WS-E4) " openers "
         FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 5 size 54 left-slot3 3 openers 1 1" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 containers given a double chest when the left half is opened then the same 54 slots show (slot 30 holds "
         & "the 3 items) and closing counts both halves down" TO TL-CASE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE 30 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE MN-CSIZE(WS-ROW) TO WS-E1
     MOVE WS-COUNT TO WS-E2
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E3
     MOVE BE-OPEN-COUNT(WS-BE2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "size " FUNCTION TRIM(WS-E1) " slot30 " FUNCTION TRIM(WS-E2) " openers " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "size 54 slot30 3 openers 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a double chest when the right half is removed then the left half is single again and "
         & "keeps its contents, and the removed half's items become ground items" TO TL-CASE
     MOVE 2 TO BE-SLOT-ITEM(WS-BE2, 7)
     MOVE 9 TO BE-SLOT-COUNT(WS-BE2, 7)
     MOVE 0 TO WS-STATE2
     COMPUTE WS-X = WS-BX + 1
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = 2
             ADD EN-ITEM-COUNT(WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E2
     MOVE BE-USED(WS-BE2) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "A " FUNCTION TRIM(WS-E1) " dropped " FUNCTION TRIM(WS-E2) " B used " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "A 1 dropped 9 B used 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given a chest holding items when the world is saved and reopened then Alice opens it and "
         & "finds slot 10 and 30's left half content" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 14)
     MOVE 21 TO BE-SLOT-COUNT(WS-BE, 14)
     CALL "BE-MARK-CHUNK" USING WS-BE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "TEST-ADD-CONTAINERS"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE 10 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-COUNT TO WS-E1
     MOVE 13 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-COUNT TO WS-E2
     MOVE MN-CSIZE(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "slot10 " FUNCTION TRIM(WS-E1) " slot13 " FUNCTION TRIM(WS-E2) " size " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slot10 33 slot13 21 size 27" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 containers given an ender chest when Alice opens it and puts a stack in then another ender chest shows "
         & "it, Bob sees his own empty one, and it survives save, reopen and rejoin" TO TL-CASE
     MOVE WS-ENDER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE WS-BZ TO WS-Z
     PERFORM USE-FLOOR
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE 2 TO WS-ITEM
     MOVE 17 TO WS-COUNT
     MOVE 8 TO WS-S
     CALL "MENU-SET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-BLOCK
     MOVE 8 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-COUNT TO WS-E2
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     CALL "TEST-USE-ON" USING WS-CONN2 WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     MOVE 8 TO WS-S
     CALL "MENU-GET" USING WS-ROW2 WS-S WS-ITEM WS-COUNT
     MOVE WS-COUNT TO WS-E3
     MOVE MN-TYPE(WS-ROW2) TO WS-E4
     CALL "TEST-CLOSE-WIN" USING WS-CONN2
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " other chest " FUNCTION TRIM(WS-E2) " bob " FUNCTION TRIM(WS-E3) " bobtype "
         FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 2 other chest 17 bob 0 bobtype 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given Alice's ender chest content when the world is saved, reopened and Alice rejoins and "
         & "opens an ender chest then slot 8 holds her 17 items" TO TL-CASE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "TEST-ADD-CONTAINERS"
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE 8 TO WS-S
     CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
     MOVE WS-ITEM TO WS-E1
     MOVE WS-COUNT TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "2x17" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 containers given a barrel when it is opened then its open state is true (block state offset 0 of the "
         & "facing) and after closing false again" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BARREL TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     MOVE WS-BZ TO WS-Z
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "minecraft:barrel" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     MOVE MN-TYPE(WS-ROW) TO WS-E3
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-E2 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     MOVE SPACES TO WS-TEXT
     STRING "open " FUNCTION TRIM(WS-E1) " closed " FUNCTION TRIM(WS-E2) " type " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "open 0 closed 1 type 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given an open shulker box when a shulker box item is put on a slot then it is refused, and "
         & "another item is accepted" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-SHULKER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     MOVE WS-BZ TO WS-Z
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE WS-RED TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 6)
     MOVE 4 TO PL-SLOT-COUNT(WS-ROW, 6)
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 58 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E1
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E2
     MOVE 59 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 4 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE MN-TYPE(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "refused " FUNCTION TRIM(WS-E1) " cursor " FUNCTION TRIM(WS-E2) " accepted " FUNCTION TRIM(WS-E3) " type "
         FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "refused 0 cursor 1 accepted 4 type 20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 containers given an open chest when the player walks out of reach and a tick runs then the menu is "
         & "closed by the server (Container Close) and the opener count drops" TO TL-CASE
     CALL "TEST-ADD-CONTAINERS"
     COMPUTE PL-X(WS-ROW) = PL-X(WS-ROW) + 40
     CALL "TEST-TICKS" USING 2
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " openers " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0 openers 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Greystone floor of 5 cells under and clear space above the position (WS-BX, WS-BY, WS-BZ) and the next three columns.
 PREPARE-GROUND.
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STATE
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STATE
         MOVE 0 TO WS-STATE2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-S = WS-BY + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-BZ WS-STATE2
         END-PERFORM
     END-PERFORM.

*> Use Item On the floor block under (WS-X, WS-BY, WS-BZ), top face, then drain.
 USE-FLOOR.
     ADD 1 TO WS-SEQ
     COMPUTE WS-Y = WS-BY - 1
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

*> Use Item On the block at WS-X, WS-Y, WS-Z, top face, the ids drained.
 USE-BLOCK.
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

*> WS-TALLY: how many times the packet id text WS-KEY(1:...) stands as a whole word of the ids drained last.
 HAS-ID.
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     EVALUATE FUNCTION TRIM(WS-KEY)
         WHEN "7"
             INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 7 "
         WHEN "60"
             INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 60 "
         WHEN "119"
             INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 119 "
     END-EVALUATE.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-CONTAINERS.

 COPY CORETEST.
 COPY BETEST.
