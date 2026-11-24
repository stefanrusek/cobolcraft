*> Test US12-client (spec 002; docs/protocol/40-menus-3 section 1, 40-menus-4 section 1, 40-menus-6 section 1): the identity tables the container screens are built from. Menu type ids of the
*> workstations: anvil 8, grindstone 15, smithing 21, enchantment 13, loom 18, stonecutter 24, cartography table 23, each with its own slot count and data slot count. The mount inventories are not a
*> MenuType: an Open Screen packet naming one of the client's mount pseudo types (100 and above) opens nothing; only Mount Screen Open does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MENU-IDENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-T4                  BINARY-LONG.
 01 WS-T5                  BINARY-LONG.
 01 WS-T6                  BINARY-LONG.
 01 WS-T7                  BINARY-LONG.
 01 WS-T8                  BINARY-LONG.
 01 WS-T9                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1 MOVE 8 TO WS-TYPE
             WHEN 2 MOVE 15 TO WS-TYPE
             WHEN 3 MOVE 21 TO WS-TYPE
         END-EVALUATE
         PERFORM FRAME-OF
     END-PERFORM
     MOVE "acceptance US12 40-3§1 Identity and shared facts: anvil (8) 3 own slots 1 data slot, grindstone (15) 3 and 0, smithing table (21) 4 and 1" TO TL-CASE
     MOVE "8:3:1 15:3:0 21:4:1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE 13 TO WS-TYPE
             WHEN 2 MOVE 18 TO WS-TYPE
             WHEN 3 MOVE 24 TO WS-TYPE
             WHEN 4 MOVE 23 TO WS-TYPE
         END-EVALUATE
         PERFORM FRAME-OF
     END-PERFORM
     MOVE "acceptance US12 40-4§1 Identity: enchantment (13) 2 own slots 10 data slots, loom (18) 4 and 1, stonecutter (24) 2 and 1, cartography table (23) 3 and 0" TO TL-CASE
     MOVE "13:2:10 18:4:1 24:2:1 23:3:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-6 section 1: an Open Screen packet with a mount pseudo type (103) opens nothing.
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 5 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 103 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-6§1 Overview: a mount inventory has no menu type, so an Open Screen packet naming the client's mount pseudo type 103 opens nothing" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-WORLD
     COMPUTE TL-OBSERVED-N = SM-SCREEN + BM-ID * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Append "type:own:data " of the menu type WS-TYPE to TL-OBSERVED.
 FRAME-OF.
     CALL "CONTAINER-FRAME" USING WS-TYPE WS-OWN WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-T6 WS-T7 WS-T8 WS-T9 WS-DATA WS-KNOWN
     MOVE WS-TYPE TO WS-E1
     MOVE WS-OWN TO WS-E2
     MOVE WS-DATA TO WS-E3
     STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 END PROGRAM TEST-MENU-IDENTITY.

 COPY CLTEST.
