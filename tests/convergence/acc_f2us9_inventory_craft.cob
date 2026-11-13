*> Convergence acceptance test of US9-1 to US9-3 (spec 002 FR-024, FR-025, FR-028; SC-005; 13 §3.5, §3.8, §3.9;
*> standin-content §13 recipe 4, one lucite and one dump_shard make two glowtube): a first-time survival Player in a
*> single-player world (the client's in-process core over a memory connection) is given a dump_shard (the standard
*> give command from chat), opens the inventory screen model, puts the lucite stack and the dump_shard in the 2 x 2
*> grid with the left button, sees the result slot show two glowtube, takes it, and the ingredient is used up in
*> the client's replica and in the world. Then the recipe book (opened with its button, the search box narrowed to
*> the recipe) places the recipe from a second dump_shard: the grid is filled from the inventory and the result
*> shows again. The client's inventory screen has no right-button slot click, so the grid is filled with whole
*> stacks (a recipe matches on one item of a kind in a cell).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US9-INVENTORY-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us9-craft".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Craft".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-SLOT.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TYPED               PIC X(64).
 01 WS-TYPED-LENGTH        BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-CORE-TOTAL          BINARY-LONG.
 01 WS-GRID                PIC X(120).
 01 WS-K                   BINARY-LONG.
 01 WS-WANTS.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 15.
 01 WS-WANT-TABLE REDEFINES WS-WANTS.
    05 WS-WANT             BINARY-LONG OCCURS 3 TIMES.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "T" TO TL-MODE

*>   The Player is given a dump_shard (item 15) by the standard give command, in the chat line.
     MOVE "/give Alice cobolcraft:dump_shard 1" TO WS-TYPED
     MOVE 35 TO WS-TYPED-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 15 TO WS-ITEM
     PERFORM TOTAL-CLIENT
     MOVE WS-TOTAL TO WS-E1
     CALL "F2C9-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
     MOVE WS-CORE-TOTAL TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "acceptance US9-1 setup given the give command when the Player gives herself a dump_shard "
         & "then the client and the world hold one" TO TL-CASE
     MOVE "client 1 core 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-3: E opens the inventory screen: the 46 menu slots.
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-STEP" USING CONVH
     MOVE "acceptance US9-3 given a Player in play when they press E then the inventory screen is open "
         & "with the 46 menu slots (46 slot widgets besides the cursor)" TO TL-CASE
     MOVE 0 TO WS-I
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-N) = WK-SLOT AND SM-W-ACTION(WS-N) = ACT-SLOT AND SM-W-ARG(WS-N) NOT = 36
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE SM-SCREEN TO WS-E1
     MOVE WS-I TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " slots " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "screen 6 slots 46" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-1: the lucite stack (item 7) into grid cell 106, the dump_shard (item 15) into cell 107.
     MOVE 7 TO WS-ITEM
     PERFORM FIND-SLOT
     PERFORM CLICK-LEFT
     MOVE 106 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 15 TO WS-ITEM
     PERFORM FIND-SLOT
     PERFORM CLICK-LEFT
     MOVE 107 TO WS-ARG
     PERFORM CLICK-LEFT
     PERFORM GRID-TEXT
     MOVE "acceptance US9-1 given the lucite stack and the dump_shard placed in the grid when the Player "
         & "looks at the result slot then it shows 2 glowtube (item 8)" TO TL-CASE
     MOVE "grid 64x7 1x15 0x0 0x0 result 2x8" TO TL-EXPECTED
     MOVE WS-GRID TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 105 TO WS-ARG
     PERFORM CLICK-LEFT
     PERFORM GRID-TEXT
     MOVE "acceptance US9-1 given the result slot when the Player takes it then the cursor holds 2 "
         & "glowtube, the dump_shard is used up and one lucite is used from the grid" TO TL-CASE
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " WS-GRID DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "cursor 2x8 grid 63x7 0x0 0x0 0x0 result 0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Closing the screen sends the cursor and the grid back into the inventory: glowtube 64 + 2, lucite 63,
*>   dump_shard none, in the client and in the world.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE PL-CARRIED-COUNT TO WS-E3
     STRING "cursor " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE WS-WANT(WS-K) TO WS-ITEM
         PERFORM TOTAL-CLIENT
         MOVE WS-TOTAL TO WS-E1
         CALL "F2C9-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
         MOVE WS-CORE-TOTAL TO WS-E2
         MOVE WS-ITEM TO WS-E3
         STRING " item " FUNCTION TRIM(WS-E3) " client " FUNCTION TRIM(WS-E1) " core "
             FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US9-1 given the result taken when the screen is closed then the cursor and the "
         & "grid return to the inventory: the client and the world agree on glowtube 66, lucite 63, "
         & "dump_shard 0" TO TL-CASE
     MOVE "cursor 0 item 8 client 66 core 66 item 7 client 63 core 63 item 15 client 0 core 0"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-2: a second dump_shard, then the recipe book. E opens the screen, the book button the panel, the
*>   search box narrows the list to "glowtube", the first cell places the recipe (Place Recipe): the grid is
*>   filled from the inventory (one set of ingredients, no Shift) and the result shows.
     MOVE "/give Alice cobolcraft:dump_shard 1" TO WS-TYPED
     MOVE 35 TO WS-TYPED-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-RB-BOOK TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "acceptance US9-2 given the inventory screen when the Player clicks the recipe book button "
         & "then the book panel opens with cells listing the known recipes" TO TL-CASE
     MOVE 0 TO WS-I
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-N) = ACT-RB-CELL
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "cells present" TO TL-EXPECTED
     MOVE "no cells" TO TL-OBSERVED
     IF WS-I > 0
         MOVE "cells present" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-RB-SEARCH TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE "glowtube" TO WS-TYPED
     MOVE 8 TO WS-TYPED-LENGTH
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM GRID-TEXT
     MOVE "acceptance US9-2 given the book narrowed to the glowtube recipe when its cell is clicked then "
         & "the grid is filled from the inventory with one lucite and one dump_shard and the result shows "
         & "2 glowtube" TO TL-CASE
     MOVE "grid 1x7 1x15 0x0 0x0 result 2x8" TO TL-EXPECTED
     MOVE WS-GRID TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 15 TO WS-ITEM
     PERFORM TOTAL-CLIENT
     MOVE WS-TOTAL TO WS-E1
     CALL "F2C9-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
     MOVE WS-CORE-TOTAL TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "acceptance US9-2 given the recipe placed when the inventory is counted then the dump_shard "
         & "is in the grid and no longer in the inventory, in the client and in the world" TO TL-CASE
     MOVE "client 0 core 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   The widget slot WS-ARG clicked with the left button, then two frames.
 CLICK-LEFT.
     MOVE CC-BUTTON-LEFT TO WS-KEY
     CALL "F2C9-CLICK" USING CONVH WS-ALICE WS-KEY WS-ARG WS-FOUND
     MOVE 2 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   WS-ARG: the first of the player's 36 slots (hotbar 0 to 8, main 9 to 35) that holds WS-ITEM.
 FIND-SLOT.
     MOVE -1 TO WS-ARG
     PERFORM VARYING WS-I FROM 36 BY -1 UNTIL WS-I < 1
         IF PL-SLOT-ITEM(WS-I) = WS-ITEM AND PL-SLOT-COUNT(WS-I) > 0
             COMPUTE WS-ARG = WS-I - 1
         END-IF
     END-PERFORM.

*>   WS-GRID: "grid <n>x<item> ..." of the four grid cells (IX 6 to 9) and "result <n>x<item>" (IX 5).
 GRID-TEXT.
     MOVE SPACES TO WS-GRID
     MOVE 1 TO WS-PTR
     STRING "grid " DELIMITED BY SIZE INTO WS-GRID WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 6 BY 1 UNTIL WS-I > 9
         MOVE IX-COUNT(WS-I) TO WS-E1
         MOVE IX-ITEM(WS-I) TO WS-E2
         STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE
             INTO WS-GRID WITH POINTER WS-PTR
     END-PERFORM
     MOVE IX-COUNT(5) TO WS-E1
     MOVE IX-ITEM(5) TO WS-E2
     STRING "result " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO WS-GRID WITH POINTER WS-PTR.

*>   WS-TOTAL: the count of WS-ITEM over the client's 36 slots.
 TOTAL-CLIENT.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-I) = WS-ITEM
             ADD PL-SLOT-COUNT(WS-I) TO WS-TOTAL
         END-IF
     END-PERFORM.
 END PROGRAM ACC-F2US9-INVENTORY-CRAFT.

*> Test helpers (test infrastructure).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2C9-CLICK.
*> USING CONVH, client index, button, argument, found out: the first ACT-SLOT widget of the client's screen
*> model whose argument is that one is pressed and released at its centre with that button, in one frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-BUTTON L-ARG L-FOUND.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO WS-W L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT OR WS-W > 0
         IF SM-W-ACTION(WS-I) = ACT-SLOT AND SM-W-ARG(WS-I) = L-ARG
             MOVE WS-I TO WS-W
         END-IF
     END-PERFORM
     IF WS-W > 0
         MOVE 1 TO L-FOUND
         COMPUTE WS-X = (SM-W-X(WS-W) + SM-W-W(WS-W) / 2) * CL-GUI-SCALE
         COMPUTE WS-Y = (SM-W-Y(WS-W) + SM-W-H(WS-W) / 2) * CL-GUI-SCALE
         CALL "CV-QUEUE" USING CONVH L-INDEX WS-DOWN L-BUTTON WS-X WS-Y
         CALL "CV-QUEUE" USING CONVH L-INDEX WS-UP L-BUTTON WS-X WS-Y
         CALL "CV-STEP" USING CONVH
     END-IF
     GOBACK.
 END PROGRAM F2C9-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2C9-CORE-TOTAL.
*> USING name (PIC X(16)), item, total out: the count of the item over that online player's 36 slots in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-R                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-ITEM                 BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ITEM L-TOTAL.
     MOVE 0 TO WS-P L-TOTAL
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64 OR WS-P > 0
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE WS-R TO WS-P
         END-IF
     END-PERFORM
     IF WS-P > 0
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
             IF PL-SLOT-ITEM(WS-P, WS-S) = L-ITEM
                 ADD PL-SLOT-COUNT(WS-P, WS-S) TO L-TOTAL
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM F2C9-CORE-TOTAL.
