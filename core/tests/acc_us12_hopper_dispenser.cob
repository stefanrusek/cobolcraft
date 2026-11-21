*> Acceptance test, US12 hopper, dispenser and dropper through the real play path (docs/protocol/31-block-entities-2 sections 5 and 6, 40-menus-1
*> sections 9 and 10; T0875 to T0878 wired): the three blocks placed with Use Item On get their entities, open as a hopper menu (type 16, 5
*> slots) and generic_3x3 menus (type 6, 9 slots) with the player's inventory after them, take and give stacks by click and shift-click,
*> send no opener Block Event and no sound (these containers have no opener counter), and keep their contents and the hopper's
*> TransferCooldown when the world is saved and reloaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-HOPPER-DISPENSER.
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
 01 WS-KEY                 PIC X(48).
 01 WS-HOPPER              BINARY-LONG.
 01 WS-DISPENSER           BINARY-LONG.
 01 WS-DROPPER             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     MOVE "minecraft:hopper" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-HOPPER
     MOVE "minecraft:dispenser" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DISPENSER
     MOVE "minecraft:dropper" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DROPPER
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STONE
     PERFORM PREPARE-GROUND
     MOVE WS-HOPPER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 hopper given a held hopper when Use Item On is sent on the floor then a hopper block with a hopper entity (type "
         & "18, cooldown -1) is placed" TO TL-CASE
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE BE-TYPE(WS-BE) TO WS-E1
     MOVE BE-COOLDOWN(WS-BE) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " cooldown " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 18 cooldown -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 hopper given a placed hopper when it is used then the hopper menu (type 16, 5 slots) opens with no opener "
         & "Block Event and no sound; a stack put on slot 2 stays in the hopper; shift-click moves it out to the inventory" TO TL-CASE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE BE-OPEN-COUNT(WS-BE) TO WS-E3
     PERFORM TALLY-EVENTS
     MOVE WS-TALLY TO WS-E4
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 12 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 36 TO WS-S
     MOVE 0 TO WS-BUTTON WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 2 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E5
     MOVE 2 TO WS-S
     MOVE 1 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = 2
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E6
     MOVE WS-COUNT TO WS-E7
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " openers " FUNCTION TRIM(WS-E3) " events "
         FUNCTION TRIM(WS-E4) " in " FUNCTION TRIM(WS-E5) " out hopper " FUNCTION TRIM(WS-E6) " inventory "
         FUNCTION TRIM(WS-E7) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 16 size 5 openers 0 events 0 in 12 out hopper 0 inventory 12" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 hopper given a dispenser and a dropper placed beside each other when each is used then the generic_3x3 menu "
         & "(type 6, 9 slots) opens, a stack shift-clicked from the inventory lands in slot 0 of the dispenser" TO TL-CASE
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-DISPENSER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     MOVE WS-DROPPER TO PL-SLOT-ITEM(WS-ROW, 1)
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 6)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 6)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 6)
     MOVE 41 TO WS-S
     MOVE 1 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E3
     MOVE BE-TYPE(WS-BE) TO WS-E4
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN
     COMPUTE WS-X = WS-BX + 1
     PERFORM USE-BLOCK
     MOVE MN-TYPE(WS-ROW) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " slot0 " FUNCTION TRIM(WS-E3) " entity " FUNCTION TRIM(WS-E4)
         " dropper type " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 6 size 9 slot0 5 entity 5 dropper type 6" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM DRAIN

     MOVE "acceptance US12 hopper given a hopper with a cooldown and a stack and a dropper with a stack when the world is saved and "
         & "reopened then both read back, the hopper's TransferCooldown too" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 4)
     MOVE 33 TO BE-SLOT-COUNT(WS-BE, 4)
     CALL "BE-MARK-CHUNK" USING WS-BE
     COMPUTE WS-Y = WS-BZ - 2
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-Y WS-BE
     MOVE 6 TO BE-COOLDOWN(WS-BE)
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 5)
     MOVE 7 TO BE-SLOT-COUNT(WS-BE, 5)
     CALL "BE-MARK-CHUNK" USING WS-BE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "TEST-ADD-CONTAINERS"
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE BE-TYPE(WS-BE) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E2
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-Y WS-BE
     MOVE BE-TYPE(WS-BE) TO WS-E3
     MOVE BE-COOLDOWN(WS-BE) TO WS-E4
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "dispenser " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " hopper " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4)
         "/" FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "dispenser 5/33 hopper 18/6/7" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

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
     PERFORM DRAIN.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

*> WS-TALLY: the Block Event (7) and Sound (119) packets of the ids drained last.
 TALLY-EVENTS.
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 7 "
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 119 ".

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-HOPPER-DISPENSER.

 COPY CORETEST.
 COPY BETEST.
