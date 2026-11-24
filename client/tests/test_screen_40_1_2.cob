*> Test US12-client (spec 002 T3182, T3183; docs/protocol/40-menus-1-model-and-containers.md section 2): the menu type registry. Open Screen (05a 0x3C) carries the
*> registry id of one of the 25 menu types (0 to 24): the 24 types other than the crafting bench (12, the bench screen) open the container screen of the client; an id with no
*> registered type (25, 99) opens nothing and the screen stays the world (2.1 notes); every open sets the container id and the menu type; the screens that need no menu type
*> (inventory, creative inventory, mounts, books, signs, command blocks) are not opened by Open Screen (2.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 24
         PERFORM OPEN-TYPE
         MOVE WS-TYPE TO WS-E1
         MOVE SM-SCREEN TO WS-E2
         STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         PERFORM CLOSE-IT
     END-PERFORM
     MOVE "acceptance US12 40-1§2 Open Screen of each of the 25 registered menu types opens a screen: the bench (12) the bench screen (19), the 24 others the container screen (20)" TO TL-CASE
     MOVE "0:20 1:20 2:20 3:20 4:20 5:20 6:20 7:20 8:20 9:20 10:20 11:20 12:19 13:20 14:20 15:20 16:20 17:20 18:20 19:20 20:20 21:20 22:20 23:20 24:20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 25 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 99 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "acceptance US12 40-1§2 an Open Screen with a type id that is not registered (25, 99) opens nothing: the screen stays the world (5)" TO TL-CASE
     MOVE "5 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE BM-ID TO WS-E1
     MOVE BM-TYPE TO WS-E2
     STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§2 the open sets the client's current menu: container id 9, type 7" TO TL-CASE
     MOVE "9:7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOSE-IT.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 17 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE SCR-WORLD TO WS-ID
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ID
     .

 OPEN-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

 END PROGRAM TEST-SCREEN-40-1-2.

 COPY CLTEST.
