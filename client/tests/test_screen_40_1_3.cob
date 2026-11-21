*> Test US12-client (spec 002 T3184, T3185; docs/protocol/40-menus-1-model-and-containers.md section 3): the menu model as the client sees it. A menu's own slots take the menu
*> indexes 0 to N-1 and the 36 player slots follow (3.3: main inventory N to N+26 = player 9 to 35, hotbar N+27 to N+35 = player 0 to 8); the crafter's result slot comes
*> after the player slots (index 45); the lectern has no player inventory. Widget arguments: own slot k is 401 + k, a player slot is its inventory number. MENU-SLOT-WIRE gives
*> the menu index that Container Click carries (3.4: slot -999 outside the image, -1 no slot) and CONTAINER-ARG its inverse.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-3.
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
 01 WS-ARG                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-LIST.
    05 FILLER PIC X(24) VALUE "401 403 009 035 000 008 ".
 01 WS-LIST-TABLE REDEFINES WS-LIST.
    05 WS-ARG-OF           PIC X(4) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE "T" TO TL-MODE
*>   Furnace (3 own slots): own 0 and 2, main 9 and 35, hotbar 0 and 8.
     MOVE 14 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 furnace: own 401 and 403 are menu slots 0 and 2, main 9 and 35 are 3 and 29, hotbar 0 and 8 are 30 and 38" TO TL-CASE
     MOVE "0 2 3 29 30 38" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 brewing stand (5 own slots): the player main run starts at 5 and the hotbar ends at 40" TO TL-CASE
     MOVE "0 2 5 31 32 40" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 merchant (3 own slots): menu slots 0, 2, 3, 29, 30, 38" TO TL-CASE
     MOVE "0 2 3 29 30 38" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 beacon (1 own slot): menu slots 0, 2 (the own slot 3 is outside: -1), 1, 27, 28, 36" TO TL-CASE
     MOVE "0 -1 1 27 28 36" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 crafter (9 crafting slots): menu slots 0, 2, main 9 and 35 are 9 and 35, hotbar 0 and 8 are 36 and 44" TO TL-CASE
     MOVE "0 2 9 35 36 44" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 410 TO WS-ARG
     CALL "MENU-SLOT-WIRE" USING CLIENT-STATE WS-ARG WS-SLOT
     MOVE WS-SLOT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 45 TO WS-SLOT
     CALL "CONTAINER-ARG" USING CLIENT-STATE WS-SLOT WS-ARG
     MOVE WS-ARG TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§3 crafter result slot: widget argument 410 is menu slot 45 and menu slot 45 is argument 410" TO TL-CASE
     MOVE "45 410" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM WIRE-LIST
     MOVE "acceptance US12 40-1§3 lectern (1 slot, no player inventory): player slots are no menu slots" TO TL-CASE
     MOVE "0 -1 -1 -1 -1 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 5 TO WS-SLOT
     CALL "CONTAINER-ARG" USING CLIENT-STATE WS-SLOT WS-ARG
     MOVE WS-ARG TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 0 TO WS-I
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-SLOT) = WK-SLOT
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE WS-I TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§3 lectern: menu slot 5 is no slot (-1) and the screen has 1 slot widget (no player inventory)" TO TL-CASE
     MOVE "-1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-TYPE
     PERFORM OPEN-TYPE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1 MOVE 401 TO WS-ARG
             WHEN 2 MOVE 409 TO WS-ARG
             WHEN 3 MOVE 410 TO WS-ARG
         END-EVALUATE
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-SLOT) = WK-SLOT AND SM-W-ARG(WS-SLOT) = WS-ARG
                 MOVE SM-W-X(WS-SLOT) TO WS-E1
                 STRING FUNCTION TRIM(WS-E1) ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 MOVE SM-W-Y(WS-SLOT) TO WS-E1
                 STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 40-1§3 crafter screen at 320 x 240 (left 72, top 37): slot 0 at (26, 17), slot 8 at (62, 53), the result (tail) slot at (134, 35), the widgets 1 pixel out" TO TL-CASE
     MOVE "97:53 133:89 205:71" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 38
         CALL "CONTAINER-ARG" USING CLIENT-STATE WS-SLOT WS-ARG
         IF WS-SLOT = 0 OR WS-SLOT = 2 OR WS-SLOT = 3 OR WS-SLOT = 29 OR WS-SLOT = 30 OR WS-SLOT = 38
             MOVE WS-ARG TO WS-E1
             STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-1§3 furnace: the inverse maps menu slots 0, 2, 3, 29, 30, 38 to arguments 401, 403, 9, 35, 0, 8" TO TL-CASE
     MOVE "401 403 9 35 0 8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The menu slot of the six arguments of WS-LIST, as a text.
 WIRE-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE FUNCTION NUMVAL(WS-ARG-OF(WS-I)) TO WS-ARG
         CALL "MENU-SLOT-WIRE" USING CLIENT-STATE WS-ARG WS-SLOT
         MOVE WS-SLOT TO WS-E1
         STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
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

 END PROGRAM TEST-SCREEN-40-1-3.

 COPY CLTEST.
