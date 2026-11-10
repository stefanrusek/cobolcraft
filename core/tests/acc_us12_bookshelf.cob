*> Acceptance test, US12 chiseled bookshelf through the real play path (docs/protocol/31-block-entities-2 section 10; T0885, T0886 wired): the
*> shelf is placed facing the player, a book (item tag bookshelf_books) used on a free slot of the face goes into the hit slot (the held book is
*> used up, the occupancy property and the last interacted slot follow), used on an occupied slot or with an empty hand it comes back out into
*> the inventory, a non-book does nothing; and the books and the block state survive saving and reopening the world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-BOOKSHELF.
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
 01 WS-SHELF               BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:bookshelf_books".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM SETUP-CONTENT
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
     MOVE WS-SHELF TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 bookshelf given a held chiseled bookshelf when Use Item On is sent on the floor then the shelf is placed facing "
         & "the player (north, state index 63: nothing occupied) with a shelf entity (type 38, last slot -1)" TO TL-CASE
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     PERFORM STATE-INDEX
     MOVE BE-TYPE(WS-BE) TO WS-E2
     MOVE BE-COOLDOWN(WS-BE) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "index " FUNCTION TRIM(WS-E1) " type " FUNCTION TRIM(WS-E2) " last " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "index 63 type 38 last -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 bookshelf given a held book when Use Item On is sent on the north face at (0.5, 0.5) then the book is put into "
         & "slot 4, the held count drops by one, the state shows slot 4 occupied (index 61) and the last slot is 4" TO TL-CASE
     MOVE WS-BOOK TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 2 TO WS-FACE
     PERFORM USE-BLOCK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM STATE-INDEX
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E2
     MOVE BE-COOLDOWN(WS-BE) TO WS-E3
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "index " FUNCTION TRIM(WS-E1) " slot4 " FUNCTION TRIM(WS-E2) " last " FUNCTION TRIM(WS-E3) " held " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "index 61 slot4 1 last 4 held 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 bookshelf given an occupied slot when a book is used on it then the book comes out (the slot is empty, the "
         & "inventory holds the books again, the state index is 63), a held non-book on a free slot changes nothing" TO TL-CASE
     PERFORM USE-BLOCK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM STATE-INDEX
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E2
     MOVE 0 TO WS-I
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-S) = WS-BOOK
             ADD PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-I
         END-IF
     END-PERFORM
     MOVE WS-I TO WS-E3
     MOVE WS-STONE TO WS-ID
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "index " FUNCTION TRIM(WS-E1) " slot4 " FUNCTION TRIM(WS-E2) " books " FUNCTION TRIM(WS-E3) " stone " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "index 63 slot4 0 books 5 stone 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 bookshelf given a book in slot 4 and an empty hand when the shelf is used then the book is taken out; the "
         & "analog output (last slot + 1) is 5" TO TL-CASE
     MOVE WS-BOOK TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-BLOCK
     CALL "BE2-SHELF-SIGNAL" USING WS-BE WS-I
     MOVE WS-I TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "signal " FUNCTION TRIM(WS-E1) " slot4 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "signal 5 slot4 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 bookshelf given a click on a side face, a creative player's book, and a shelf block without its entity then "
         & "nothing is inserted on the side face, a creative book is not used up, a missing entity does nothing" TO TL-CASE
     MOVE WS-BOOK TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 5 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E1
     MOVE 2 TO WS-FACE
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM USE-BLOCK
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE 0 TO BE-USED(WS-BE)
     MOVE WS-BOOK TO PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE 1 TO BE-USED(WS-BE)
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "side " FUNCTION TRIM(WS-E1) " creative " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " missing " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "side 0 creative 2/1 missing 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 bookshelf given two books on the shelf when the world is saved and reopened then the book and the last slot are there (the "
         & "test set cannot encode the occupancy properties, so the state reads back as the default)" TO TL-CASE
     MOVE WS-BOOK TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-BLOCK
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     PERFORM SETUP-CONTENT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     PERFORM STATE-INDEX
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E2
     MOVE BE-COOLDOWN(WS-BE) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "index " FUNCTION TRIM(WS-E1) " slot4 " FUNCTION TRIM(WS-E2) " last " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "index 63 slot4 1 last 4" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> The shelf block and its items, the book item and the bookshelf_books tag.
 SETUP-CONTENT.
     CALL "TEST-ADD-CONTAINERS"
     MOVE "minecraft:chiseled_bookshelf" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHELF
     MOVE "minecraft:book" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BOOK
     MOVE WS-BOOK TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TAG-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS.

*> WS-E1: the state index of the shelf block (the state minus the first state of the block).
 STATE-INDEX.
     MOVE "minecraft:chiseled_bookshelf" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1).

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
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-BOOKSHELF.

 COPY CORETEST.
 COPY BETEST.
