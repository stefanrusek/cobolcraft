*> Test of the small recipe book packets (core/src/recipe-packets.cob, play.cob; docs/protocol/27 section 4.4 and 4.7, 05a 0x40, 05c 0x2F
*> and 0x30; T3655 to T3657): Recipe Book Change Settings stores the open and filtering flags of the book type, Recipe Book
*> Seen clears the unseen highlight of the recipe of the display id, and a Place Recipe the inventory cannot supply is
*> answered with Place Ghost Recipe (0x40: the container id and the recipe's display) after the grid went back into the
*> inventory, while a Place Recipe that succeeds sends none. Items: greystone 2 (the starting kit); display 4 is the
*> glowtube recipe (lucite, dump_shard), which the starting kit cannot supply; display 0 is the ledger_tile recipe.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-PACKETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY RECBOOK.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-BIG                 BINARY-LONG VALUE 65536.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SEEN-ID             BINARY-LONG VALUE 48.
 01 WS-SETTINGS-ID         BINARY-LONG VALUE 47.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-DISPLAY             BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-IDS                 PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW

     MOVE "test recipe packets Recipe Book Change Settings of the furnace book (open, not filtering) and the smoker "
         & "book (closed, filtering) are stored per book type" TO TL-CASE
     MOVE 1 TO WS-TYPE WS-OPEN
     MOVE 0 TO WS-FILTER
     PERFORM SEND-SETTINGS
     MOVE 3 TO WS-TYPE
     MOVE 0 TO WS-OPEN
     MOVE 1 TO WS-FILTER
     PERFORM SEND-SETTINGS
     MOVE RB-OPEN(WS-ROW, 2) TO WS-EDIT
     MOVE RB-FILTER(WS-ROW, 2) TO WS-EDIT2
     MOVE RB-OPEN(WS-ROW, 4) TO WS-EDIT3
     MOVE RB-FILTER(WS-ROW, 4) TO WS-EDIT4
     MOVE SPACES TO TL-OBSERVED
     STRING "furnace " FUNCTION TRIM(WS-EDIT) FUNCTION TRIM(WS-EDIT2) " smoker " FUNCTION TRIM(WS-EDIT3)
         FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "furnace 10 smoker 01" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe packets Recipe Book Seen of display 0 clears the highlight of its recipe and keeps the others"
         TO TL-CASE
     MOVE 1 TO RB-HIGHLIGHT(WS-ROW, 1) RB-HIGHLIGHT(WS-ROW, 2)
     MOVE 0 TO WS-DISPLAY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SEEN-ID
     CALL "PB-PUT-RECIPE-SEEN" USING PB-BUFFER WS-DISPLAY
     CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE RB-HIGHLIGHT(WS-ROW, 1) TO WS-EDIT
     MOVE RB-HIGHLIGHT(WS-ROW, 2) TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING "recipe 1 " FUNCTION TRIM(WS-EDIT) " recipe 2 " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "recipe 1 0 recipe 2 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe packets Recipe Book Seen of a display id no recipe has changes nothing" TO TL-CASE
     MOVE 9999 TO WS-DISPLAY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SEEN-ID
     CALL "PB-PUT-RECIPE-SEEN" USING PB-BUFFER WS-DISPLAY
     CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE RB-HIGHLIGHT(WS-ROW, 2) TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "recipe 2 " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "recipe 2 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe packets a Place Recipe the inventory cannot supply (glowtube) is answered with Place Ghost "
         & "Recipe for container 0 after the Container Set Content" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     CALL "TEST-PLACE-RECIPE" USING WS-ID WS-FOUR
     CALL "PB-INIT" USING PB-BUFFER WS-BIG
     CALL "PB-INIT" USING PK-BUFFER WS-BIG
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             MOVE WS-PACKET-ID TO WS-EDIT
             IF WS-PACKET-ID = 64
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-C
                 MOVE WS-A TO WS-EDIT2
                 MOVE WS-B TO WS-EDIT3
                 MOVE WS-C TO WS-EDIT4
                 STRING FUNCTION TRIM(WS-TEXT) " 64(container " FUNCTION TRIM(WS-EDIT2) " type "
                     FUNCTION TRIM(WS-EDIT3) " ingredients " FUNCTION TRIM(WS-EDIT4) ")"
                     DELIMITED BY SIZE INTO TL-OBSERVED
                 MOVE TL-OBSERVED TO WS-TEXT
             ELSE
                 MOVE SPACES TO TL-OBSERVED
                 STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
                 MOVE TL-OBSERVED TO WS-TEXT
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "18 64(container 0 type 0 ingredients 2)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe packets a Place Recipe that succeeds (display 0) sends no Place Ghost Recipe" TO TL-CASE
     MOVE 0 TO WS-DISPLAY
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     CALL "TEST-PLACE-RECIPE" USING WS-ID WS-DISPLAY
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     MOVE "18" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 SEND-SETTINGS.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SETTINGS-ID
     CALL "PB-PUT-RECIPE-BOOK-CHANGE" USING PB-BUFFER WS-TYPE WS-OPEN WS-FILTER
     CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPE-PACKETS.
 COPY CORETEST.
