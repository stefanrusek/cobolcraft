*> Acceptance test US10-2 (spec 002 FR-026, FR-027; SC-005; 12 §5.6b; 13 §3.5; contract fixtures play-s2c-3c-open-screen-crafting and
*> play-s2c-12-container-set-content-crafting-bench): Open Screen for the crafting menu (type 12, container 2) shows the bench screen; its
*> Container Set Content fills the result (1 x cobblestone), the grid and the hotbar; the screen is the 46-slot bench menu on the crafting-table
*> sheet at (72, 37) of a 320 x 240 GUI: 46 bare slots (result at cell (196, 72), the 3 x 3 grid from (102, 54), main from (80, 121), hotbar from
*> (80, 179)) and no armour or off-hand slot; clicks send Container Click of container 2 with the bench's slot numbers (37, 10, 0, 1); closing
*> sends Container Close of container 2 and shows the world; a Container Close from the server does too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US10-BENCH-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 15.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-OTHER               BINARY-LONG VALUE 5.
 01 WS-STATE7              BINARY-LONG VALUE 7.
 01 WS-STATE4              BINARY-LONG VALUE 4.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-E                   PIC Z(8)9.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ARGS.
    05 FILLER PIC 999 VALUE 105.
    05 FILLER PIC 999 VALUE 106.
    05 FILLER PIC 999 VALUE 114.
    05 FILLER PIC 999 VALUE 9.
    05 FILLER PIC 999 VALUE 0.
 01 WS-ARG-TABLE REDEFINES WS-ARGS.
    05 WS-CLICK-ARG        PIC 999 OCCURS 5 TIMES.
 01 WS-PLACES.
    05 FILLER PIC 9(9) VALUE 196072.
    05 FILLER PIC 9(9) VALUE 102054.
    05 FILLER PIC 9(9) VALUE 138090.
    05 FILLER PIC 9(9) VALUE 080121.
    05 FILLER PIC 9(9) VALUE 080179.
 01 WS-PLACE-TABLE REDEFINES WS-PLACES.
    05 WS-PLACE            PIC 9(9) OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE "contract/fixtures/wire/play-s2c-3c-open-screen-crafting.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "N" TO TL-MODE
     MOVE "acceptance US10-2 Open Screen of the crafting menu (type 12, container 2) shows the bench screen" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-BENCH * 1000 + 2
     COMPUTE TL-OBSERVED-N = SM-SCREEN * 1000 + BM-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-FEED-BENCH-ITEMS" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE
*>   A Container Set Content for a container that is not open (5) changes nothing: not the slots, not the bench's state id.
     CALL "TEST-FEED-BENCH-ITEMS" USING CLIENT-STATE WS-CONN WS-OTHER WS-STATE7
     MOVE "acceptance US10-2 a Container Set Content of container 5 (not open) does not change the bench's state id (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BM-STATE-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-SLOT
     MOVE 4 TO WS-COUNT
     MOVE 99 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-OTHER WS-STATE7 WS-SLOT WS-COUNT WS-ITEM
     MOVE "acceptance US10-2 a Container Set Slot of container 5 (not open) changes no bench slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BX-COUNT(14) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Bench slot 10 is the first main-inventory slot (player slot 9), 36 the last (player slot 35), 45 the last hotbar slot (player slot 8).
     MOVE 10 TO WS-SLOT
     MOVE 7 TO WS-COUNT
     MOVE 3 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE 45 TO WS-SLOT
     MOVE 8 TO WS-COUNT
     MOVE 4 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE "acceptance US10-2 bench slot 10 is player slot 9 (7 x 3) and bench slot 45 player slot 8 (8 x 4)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (7 * 1000 + 3) * 1000000 + 8 * 1000 + 4
     COMPUTE TL-OBSERVED-N = (PL-SLOT-COUNT(10) * 1000 + PL-SLOT-ITEM(10)) * 1000000 + PL-SLOT-COUNT(9) * 1000 + PL-SLOT-ITEM(9)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A Container Set Slot of the bench: grid slot 9 (menu 9) and its state id; of container 0: the menu slot 5 is the helmet.
     MOVE 9 TO WS-SLOT
     MOVE 3 TO WS-COUNT
     MOVE 62 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE4 WS-SLOT WS-COUNT WS-ITEM
     MOVE "acceptance US10-2 a Container Set Slot of the bench sets grid slot 9 (3 x 62) and the state id 4" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 1000000 + 62 * 1000 + 4
     COMPUTE TL-OBSERVED-N = BX-COUNT(14) * 1000000 + BX-ITEM(14) * 1000 + BM-STATE-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CONTAINER
     MOVE 5 TO WS-SLOT
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE7 WS-SLOT WS-COUNT WS-ITEM
     MOVE 2 TO WS-CONTAINER
     MOVE "acceptance US10-2 a Container Set Slot of container 0 slot 5 sets the helmet (inventory extra 1), not the bench" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (3 * 1000 + 62) * 1000 + 0
     COMPUTE TL-OBSERVED-N = (IX-COUNT(1) * 1000 + IX-ITEM(1)) * 1000 + BX-COUNT(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "acceptance US10-2 the result slot holds 1 x cobblestone (item 62)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 62
     COMPUTE TL-OBSERVED-N = BX-COUNT(5) * 1000 + BX-ITEM(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US10-2 grid slots 1 and 5 hold 1 x oak planks (item 63)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 63 + 1000000 * (1 * 1000 + 63)
     COMPUTE TL-OBSERVED-N = BX-COUNT(6) * 1000 + BX-ITEM(6) + 1000000 * (BX-COUNT(10) * 1000 + BX-ITEM(10))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US10-2 menu slot 37 is hotbar slot 0: 64 x stone" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 1000 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 1000 + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The layout.
     MOVE 0 TO WS-N WS-M
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT
             ADD 1 TO WS-N
             IF SM-W-ARG(WS-I) = 37 OR (SM-W-ARG(WS-I) >= 101 AND SM-W-ARG(WS-I) <= 104)
                 ADD 1 TO WS-M
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US10-2 the bench screen has 46 slot widgets (36 + the result + 9 grid)" TO TL-CASE
     MOVE 46 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US10-2 the bench has no armour and no off-hand slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-M TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SHEET
             COMPUTE WS-N = SM-W-ARG(WS-I) * 1000000 + SM-W-X(WS-I) * 1000 + SM-W-Y(WS-I)
         END-IF
     END-PERFORM
     MOVE "acceptance US10-2 the crafting-table sheet is at (72, 37)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = GSP-SHEET-BENCH * 1000000 + 72 * 1000 + 37
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-CLICK-ARG(WS-K)
                 COMPUTE WS-N = (SM-W-X(WS-I) + 1) * 1000 + SM-W-Y(WS-I) + 1
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         MOVE WS-CLICK-ARG(WS-K) TO WS-E
         STRING "acceptance US10-2 the slot widget of argument " FUNCTION TRIM(WS-E) " is at its place of 12 5.6b"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-PLACE(WS-K) TO TL-EXPECTED-N
         MOVE WS-N TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Clicks carry container 2, the bench's state id 1 and the bench's slot numbers: result 0, grid slot 1, grid slot 9 (menu 9), main 10, hotbar 37.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE WS-CLICK-ARG(WS-K) TO WS-ARG
         CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         STRING FUNCTION TRIM(TL-OBSERVED) " " WS-TEXT(1:10) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US10-2 clicks send Container Click of container 2, state 4 and the bench slots 0, 1, 9, 10 and 37" TO TL-CASE
     MOVE "1202040000 1202040001 1202040009 120204000a 1202040025" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Closing: E sends Container Close of container 2 and shows the world.
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING FUNCTION TRIM(WS-TEXT) " screen " FUNCTION TRIM(WS-E) " bench " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE BM-ID TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US10-2 closing the bench sends Container Close of container 2 and shows the world" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-WORLD TO WS-E
     STRING "1302 screen " FUNCTION TRIM(WS-E) " bench0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server closes a bench: Container Close 0x11 of the open container returns to the world and sends nothing.
     MOVE "contract/fixtures/wire/play-s2c-3c-open-screen-crafting.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-FEED-CLOSE" USING CLIENT-STATE WS-CONN WS-CONTAINER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING "sent [" FUNCTION TRIM(WS-TEXT) "] screen " FUNCTION TRIM(WS-E) " bench " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE BM-ID TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US10-2 a Container Close from the server shows the world and sends nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-WORLD TO WS-E
     STRING "sent [] screen " FUNCTION TRIM(WS-E) " bench0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US10-BENCH-SCREEN.

 COPY CLTEST.
