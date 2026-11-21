*> Convergence acceptance test of US10-1 to US10-4 (spec 002 FR-026, FR-027; SC-005; 12 §5.6b; 13 §3.5; standin-content
*> §1.1 the bench block, §13 recipe 7: four ledger_tile, two dump_shard and a glowtube make a goto_pad, which needs the
*> 3 x 3 grid): a first-time survival Player in a single-player world crafts the cobolcraft:crafting_bench in the
*> inventory (the recipe book places the shaped recipe of four ledger_tile), puts it in the hotbar and places it on the
*> turf top at (6, 53, 8); the world and the client's replica show the bench block. The recipe of seven ingredients is
*> not offered by the 2 x 2 inventory screen. Used on the bench block, the crafting screen opens with the large grid;
*> the recipe book places the seven ingredients and the result is taken: a goto_pad.
*> Spawn (4.5, 54, 8.5) facing east.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US10-BENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us10-bench".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Bench".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TYPED               PIC X(64).
 01 WS-TYPED-LENGTH        BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-CORE-TOTAL          BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CORE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-GRID                PIC X(160).
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

*>   Two dump_shards (item 15) from the give command: with the starting ledger_tile and glowtube they are the
*>   ingredients of recipe 7.
     MOVE "/give Alice cobolcraft:dump_shard 2" TO WS-TYPED
     MOVE 35 TO WS-TYPED-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   US10-3: the inventory screen does not offer the recipe of seven ingredients.
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     PERFORM OPEN-BOOK
     MOVE "goto" TO WS-TYPED
     MOVE 4 TO WS-TYPED-LENGTH
     PERFORM SEARCH-FOR
     PERFORM COUNT-CELLS
     MOVE "acceptance US10-3 given the ingredients of the goto_pad recipe when the Player searches the "
         & "inventory screen's recipe book for it then no cell offers it (it needs the large grid)" TO TL-CASE
     MOVE "cells 0" TO TL-EXPECTED
     MOVE WS-CELLS TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "cells " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-1: the bench recipe (shaped, four ledger_tile) placed by the recipe book, the result taken.
     MOVE "bench" TO WS-TYPED
     MOVE 5 TO WS-TYPED-LENGTH
     PERFORM SEARCH-FOR
     PERFORM COUNT-CELLS
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM GRID-TEXT
     MOVE "acceptance US10-1 given the ledger_tile in the inventory when the Player places the bench "
         & "recipe from the book then the grid holds four ledger_tile and the result is the "
         & "crafting_bench (item 18)" TO TL-CASE
     MOVE "grid 1x9 1x9 1x9 1x9 result 1x18" TO TL-EXPECTED
     MOVE WS-GRID TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 105 TO WS-ARG
     PERFORM CLICK-LEFT
*>   The bench on the cursor goes onto hotbar slot 8 (the pry_bar is swapped out onto an empty slot).
     MOVE 8 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 0 TO WS-ITEM
     PERFORM FIND-SLOT
     PERFORM CLICK-LEFT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 18 TO WS-ITEM
     PERFORM TOTAL-CLIENT
     MOVE WS-TOTAL TO WS-E1
     CALL "F2CB-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
     MOVE WS-CORE-TOTAL TO WS-E2
     MOVE PL-SLOT-ITEM(9) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "bench client " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) " hotbar 8 item "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US10-1 given the crafting_bench taken from the result when the screen is closed "
         & "then the client and the world hold one, in hotbar slot 8" TO TL-CASE
     MOVE "bench client 1 core 1 hotbar 8 item 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hotbar slot 8 (key 9) selected, the bench placed on the turf top at (6, 53, 8) with the use control.
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "F2CB-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE "acceptance US10-1 given the Player holds the bench item and aims at the top of the turf when "
         & "they use the place control then the crafting_bench block (state 18) stands there in the "
         & "world and in the client's replica" TO TL-CASE
     MOVE "core 18 client 18" TO TL-EXPECTED
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-2: used on the placed bench (hotbar slot 0, greystone, in hand: a block in hand does not stop the
*>   bench opening), the crafting screen opens with the large grid.
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "F2CB-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "acceptance US10-2 given the placed bench when the Player uses it then the crafting screen "
         & "opens (the bench screen, a container id given)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-BENCH AND BM-ID > 0
         MOVE "bench screen" TO TL-OBSERVED
     ELSE
         MOVE SM-SCREEN TO WS-E1
         STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "bench screen" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-2: the empty hand uses the bench too (hotbar slot 8 is empty: the bench item was used up): the screen opens again after it is
*>   closed with Escape.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "acceptance US10-2 given the bench screen when the Player presses Escape then the world "
         & "screen shows again and no bench is open" TO TL-CASE
     MOVE SM-SCREEN TO WS-E1
     MOVE BM-ID TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " bench " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "screen 5 bench 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     PERFORM USE-BUTTON
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "acceptance US10-2 given the placed bench and an empty hand when the Player uses the bench "
         & "then the crafting screen opens" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-BENCH AND BM-ID > 0
         MOVE "bench screen" TO TL-OBSERVED
     ELSE
         MOVE SM-SCREEN TO WS-E1
         STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "bench screen" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Back at the bench with a block in hand for the 3 x 3 recipe below (whatever the case above found).
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     IF SM-SCREEN NOT = SCR-BENCH
         PERFORM USE-BUTTON
         MOVE 3 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-IF

*>   US10-2, US10-3: the recipe book at the bench offers the recipe of seven ingredients; placing it fills
*>   seven cells of the 3 x 3 grid, and taking the result makes the goto_pad (item 16).
     PERFORM OPEN-BOOK
     MOVE "goto" TO WS-TYPED
     MOVE 4 TO WS-TYPED-LENGTH
     PERFORM SEARCH-FOR
     PERFORM COUNT-CELLS
     MOVE "acceptance US10-3 given the bench screen when the Player searches the book for the goto_pad "
         & "then it is offered (one cell)" TO TL-CASE
     MOVE "cells 1" TO TL-EXPECTED
     MOVE WS-CELLS TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "cells " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM BENCH-TEXT
     MOVE "acceptance US10-3 given the goto_pad recipe placed at the bench when the Player looks at the "
         & "3 x 3 grid then it holds four ledger_tile, two dump_shard and a glowtube and the result is a "
         & "goto_pad" TO TL-CASE
     MOVE WS-GRID TO TL-OBSERVED
     MOVE "grid 1x9 1x9 1x9 1x9 1x15 1x15 1x8 0x0 0x0 result 1x16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 105 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM BENCH-TEXT
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " WS-GRID DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "acceptance US10-3 given the goto_pad in the result slot when the Player takes it then the "
         & "cursor holds it and the nine grid cells and the result are empty" TO TL-CASE
     MOVE "cursor 1x16 grid 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0 result 0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   The widget slot WS-ARG clicked with the left button, then two frames.
 CLICK-LEFT.
     MOVE CC-BUTTON-LEFT TO WS-KEY
     CALL "F2CB-CLICK" USING CONVH WS-ALICE WS-KEY WS-ARG WS-FOUND
     MOVE 2 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   WS-ARG: the first of the player's 36 slots holding WS-ITEM (item 0: an empty slot).
 FIND-SLOT.
     MOVE -1 TO WS-ARG
     PERFORM VARYING WS-I FROM 36 BY -1 UNTIL WS-I < 1
         IF PL-SLOT-ITEM(WS-I) = WS-ITEM
             COMPUTE WS-ARG = WS-I - 1
         END-IF
     END-PERFORM.

*>   The recipe book button, unless the panel is open already.
 OPEN-BOOK.
     IF RK-OPEN(1) = 0
         MOVE ACT-RB-BOOK TO WS-ACTION
         MOVE 0 TO WS-ARG
         CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
         MOVE 3 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-IF.

*>   The search box emptied (Backspace) and the text typed.
 SEARCH-FOR.
     MOVE ACT-RB-SEARCH TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     END-PERFORM
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   WS-CELLS: the recipe cells of the screen model.
 COUNT-CELLS.
     MOVE 0 TO WS-CELLS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-N) = ACT-RB-CELL
             ADD 1 TO WS-CELLS
         END-IF
     END-PERFORM.

*>   WS-GRID: "grid <n>x<item> ..." of the inventory's four grid cells (IX 6 to 9) and "result" (IX 5).
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

*>   The same for the bench's nine grid cells (BX 6 to 14) and result (BX 5).
 BENCH-TEXT.
     MOVE SPACES TO WS-GRID
     MOVE 1 TO WS-PTR
     STRING "grid " DELIMITED BY SIZE INTO WS-GRID WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 6 BY 1 UNTIL WS-I > 14
         MOVE BX-COUNT(WS-I) TO WS-E1
         MOVE BX-ITEM(WS-I) TO WS-E2
         STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE
             INTO WS-GRID WITH POINTER WS-PTR
     END-PERFORM
     MOVE BX-COUNT(5) TO WS-E1
     MOVE BX-ITEM(5) TO WS-E2
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

*>   A use (right button down and up, two frames, then one more for the answer).
 USE-BUTTON.
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   The cell WS-X, WS-Y, WS-Z in the world and in the client's replica.
 BLOCK-BOTH.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-CORE
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-LIGHT.
 END PROGRAM ACC-F2US10-BENCH.

*> Test helpers (test infrastructure).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CB-AIM-AT.
*> USING CLIENT-STATE, target x, y, z (FLOAT-LONG): the local player looks from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X; positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - PL-Y - 1.6
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-NX = 0 - WS-DX
     CALL "F2CB-ATAN2-DEG" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "F2CB-ATAN2-DEG" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM F2CB-AIM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CB-ATAN2-DEG.
*> USING y, x, angle out (FLOAT-LONG, degrees, -180 to 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) + FUNCTION PI
         WHEN L-X < 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) - FUNCTION PI
         WHEN L-Y > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-Y < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-A = WS-A * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM F2CB-ATAN2-DEG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CB-CLICK.
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
 END PROGRAM F2CB-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CB-CORE-TOTAL.
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
 END PROGRAM F2CB-CORE-TOTAL.
