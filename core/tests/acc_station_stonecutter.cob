*> Acceptance test, the stonecutter menu through the real play path (docs/protocol/40-menus-4 section 4; 27 section 3.2; 002-lane-stations T5200): Use
*> Item On a stonecutter opens menu type 24 (2 own slots, title container.stonecutter); the list is the stonecutting recipes of the input item in store
*> order; Container Button Click selects an entry and sets up the result; taking the result uses one input item and assembles the result again; a shift
*> click on the result moves it to the inventory; the input slot's kind change resets the selection; the result slot takes nothing; closing returns the
*> input; the menu closes when the block is gone; a sneaking player with an item in hand does not open it. Standard block and item tables with four
*> stonecutting recipes written into the recipe store here.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-STATION-STONECUTTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CTRECIPE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-STONE-BLOCK         BINARY-LONG.
 01 WS-CUTTER              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-SLAB                BINARY-LONG.
 01 WS-BRICKS              BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-CSLAB               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-WINDOW              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-RITEM               BINARY-LONG.
 01 WS-RCOUNT              BINARY-LONG.
 01 WS-RET                 BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-TITLE               PIC X(48).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE "stone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE-BLOCK
     MOVE "stonecutter" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-CUTTER
     MOVE "stone" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STONE
     MOVE "stone_slab" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SLAB
     MOVE "stone_bricks" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BRICKS
     MOVE "stone_stairs" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STAIRS
     MOVE "cobblestone" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-COBBLE
     MOVE "cobblestone_slab" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-CSLAB
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
     PERFORM LOAD-RECIPES
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM

     MOVE "acceptance station stonecutter list: stone has three entries in store order, cobblestone one, dirt and nothing none" TO TL-CASE
     CALL "MENU-STONE-COUNT" USING WS-STONE WS-SIZE
     MOVE WS-SIZE TO WS-E1
     CALL "MENU-STONE-COUNT" USING WS-COBBLE WS-SIZE
     MOVE WS-SIZE TO WS-E2
     CALL "MENU-STONE-COUNT" USING WS-DIRT WS-SIZE
     MOVE WS-SIZE TO WS-E3
     MOVE 0 TO WS-I
     CALL "MENU-STONE-COUNT" USING WS-I WS-SIZE
     MOVE WS-SIZE TO WS-E4
     MOVE 1 TO WS-I
     CALL "MENU-STONE-NTH" USING WS-STONE WS-I WS-RITEM WS-RCOUNT
     IF WS-RITEM = WS-SLAB
         MOVE 1 TO WS-E5
     ELSE
         MOVE 0 TO WS-E5
     END-IF
     MOVE WS-RCOUNT TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " second " FUNCTION TRIM(WS-E5) " x"
         FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "3 1 0 0 second 1 x2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter list: an index outside the list, a negative index and a result of an unknown item give nothing" TO TL-CASE
     MOVE 3 TO WS-I
     CALL "MENU-STONE-NTH" USING WS-STONE WS-I WS-RITEM WS-RCOUNT
     MOVE WS-RCOUNT TO WS-E1
     MOVE -1 TO WS-I
     CALL "MENU-STONE-NTH" USING WS-STONE WS-I WS-RITEM WS-RCOUNT
     MOVE WS-RCOUNT TO WS-E2
     MOVE 0 TO WS-I
     CALL "MENU-STONE-NTH" USING WS-DIRT WS-I WS-RITEM WS-RCOUNT
     MOVE WS-RCOUNT TO WS-E3
     MOVE 0 TO WS-I
     MOVE "minecraft:no_such_item" TO RR-RESULT-ID(2)
     CALL "MENU-STONE-NTH" USING WS-STONE WS-I WS-RITEM WS-RCOUNT
     MOVE WS-RCOUNT TO WS-E4
     MOVE "minecraft:stone_slab" TO RR-RESULT-ID(2)
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0 0 0 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter identity: kinds of blocks and the identity tables of the eight stations" TO TL-CASE
     CALL "MENU-STATION-KIND" USING WS-CUTTER WS-I
     MOVE WS-I TO WS-E1
     CALL "MENU-STATION-KIND" USING WS-STONE-BLOCK WS-I
     MOVE WS-I TO WS-E2
     MOVE -5 TO WS-STATE2
     CALL "MENU-STATION-KIND" USING WS-STATE2 WS-I
     MOVE WS-I TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 0 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "MENU-STATION-INFO" USING WS-I WS-TYPE WS-OWN WS-RES WS-TITLE
         MOVE WS-TYPE TO WS-E1
         MOVE WS-OWN TO WS-E2
         MOVE WS-RES TO WS-E3
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     END-PERFORM
     MOVE "acceptance station identity: type, own slots and result slot of the eight stations" TO TL-CASE
     MOVE "24/2/1 15/3/2 21/4/3 8/3/2 18/4/3 23/3/2 13/2/-1 11/5/-1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT
     PERFORM CHECK

     MOVE WS-STONE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 10 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-CUTTER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE "acceptance station stonecutter open: Use Item On opens menu 24 with 2 own slots, the Open Screen (60) and the content packet arrive" TO TL-CASE
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 60"
     MOVE WS-TALLY TO WS-E3
     MOVE MN-WSEL(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " open " FUNCTION TRIM(WS-E3) " sel " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 24 size 2 open 1 sel -1" TO TL-EXPECTED
     PERFORM CHECK
     MOVE MN-WINDOW(WS-ROW) TO WS-WINDOW

     MOVE "acceptance station stonecutter input: a shift click on a hotbar stack of stone moves it to the input slot" TO TL-CASE
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 29 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE MN-WSEL(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " hotbar " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) " sel " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 10 hotbar 0 result 0 sel -1" TO TL-EXPECTED
     PERFORM CHECK

     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance station stonecutter list packet: an Update Recipes (136) went out with the shift click that put stone in the input slot" TO TL-CASE
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 136"
     MOVE WS-TALLY TO WS-E1
     IF MN-WLIST(WS-ROW) = WS-STONE
         MOVE 1 TO WS-E3
     ELSE
         MOVE 0 TO WS-E3
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "sent " FUNCTION TRIM(WS-E1) " list " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sent 1 list 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter button: button 1 selects the second entry, the result slot holds 2 stone slabs and data slot 0 (19) is sent" TO TL-CASE
     MOVE 1 TO WS-BUTTON
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-WINDOW WS-BUTTON
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 19"
     MOVE WS-TALLY TO WS-E1
     MOVE MN-WSEL(WS-ROW) TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     IF MN-RESULT-ITEM(WS-ROW) = WS-SLAB
         MOVE 1 TO WS-E4
     ELSE
         MOVE 0 TO WS-E4
     END-IF
     MOVE MN-STATE-ID(WS-ROW) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "data " FUNCTION TRIM(WS-E1) " sel " FUNCTION TRIM(WS-E2) " count " FUNCTION TRIM(WS-E3) " slab " FUNCTION TRIM(WS-E4) " state "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "data 1 sel 1 count 2 slab 1 state 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter button: the same button again, an id past the list and a click on another container change nothing" TO TL-CASE
     MOVE MN-STATE-ID(WS-ROW) TO WS-E5
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-WINDOW WS-BUTTON
     MOVE 9 TO WS-BUTTON
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-WINDOW WS-BUTTON
     MOVE 2 TO WS-BUTTON
     COMPUTE WS-I = WS-WINDOW + 1
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-I WS-BUTTON
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE MN-STATE-ID(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2) " state " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     STRING "sel 1 count 2 state " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-KEY
     MOVE WS-KEY TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter button: a button of container 0 while the stonecutter is open is ignored" TO TL-CASE
     MOVE 0 TO WS-I
     MOVE 0 TO WS-BUTTON
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-I WS-BUTTON
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter take: picking the result up by click gives 2 slabs on the cursor, uses one stone and assembles the result again" TO TL-CASE
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 1 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE MN-WSEL(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " input " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) " sel " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 2 input 9 result 2 sel 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter result slot: the cursor's stone slabs fill up from the result when it fits, a foreign stack is refused" TO TL-CASE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE WS-DIRT TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " input " FUNCTION TRIM(WS-E2) " dirt " FUNCTION TRIM(WS-E3) " result " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 4 input 8 dirt 1 result 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter quick move: a shift click on the result puts the slabs into the inventory (main inventory from the end) and uses "
         & "one stone per click of the loop" TO TL-CASE
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO WS-TYPE
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-SLAB
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " slabs " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 0 slabs 16 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter take: when the last input item is used up the selection resets to -1 and the result is empty" TO TL-CASE
     MOVE WS-STONE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO WS-I
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE 1 TO WS-I
     CALL "MENU-STATION-BUTTON" USING WS-ROW WS-I WS-RET
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 1 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSEL(WS-ROW) TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " sel " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) " cursor " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 0 sel -1 result 0 cursor 2" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW)

     MOVE "acceptance station stonecutter list reset: replacing the input with another kind resets the selection, a count change keeps it" TO TL-CASE
     MOVE WS-STONE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO MN-WSLOT-COUNT(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE 2 TO WS-I
     CALL "MENU-STATION-BUTTON" USING WS-ROW WS-I WS-RET
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE 3 TO MN-WSLOT-COUNT(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WSEL(WS-ROW) TO WS-E2
     MOVE WS-COBBLE TO MN-WSLOT-ITEM(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WSEL(WS-ROW) TO WS-E3
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "picked " FUNCTION TRIM(WS-E1) " kept " FUNCTION TRIM(WS-E2) " reset " FUNCTION TRIM(WS-E3) " result " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "picked 2 kept 2 reset -1 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter quick move: stone from the inventory goes to the input slot, a stack without a recipe moves between the main "
         & "inventory and the hotbar, the input slot goes back to the inventory" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-COBBLE TO PL-SLOT-ITEM(WS-ROW, 10)
     MOVE 4 TO PL-SLOT-COUNT(WS-ROW, 10)
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 11)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 11)
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 1 TO WS-TYPE
     MOVE 2 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-SLOT-COUNT(WS-ROW, 11) TO WS-E2
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-DIRT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E3
     MOVE 29 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 10 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-DIRT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E4
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " main " FUNCTION TRIM(WS-E2) " hotbar " FUNCTION TRIM(WS-E3) " back " FUNCTION TRIM(WS-E4) " out "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 4 main 0 hotbar 5 back 5 out 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter close: the input slot goes back to the inventory and the menu is closed" TO TL-CASE
     MOVE WS-STONE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 6 TO MN-WSLOT-COUNT(WS-ROW, 1)
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-STONE
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "window " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " stone " FUNCTION TRIM(WS-E3) " left " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0 size 0 stone 6 left 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter sneaking: a sneaking player holding an item uses the item, no menu opens; an empty hand opens it" TO TL-CASE
     MOVE 1 TO PL-SNEAKING(WS-ROW)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 4 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE "closed" TO WS-KEY
     IF MN-WINDOW(WS-ROW) > 0
         MOVE "open" TO WS-KEY
     END-IF
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1) PL-SLOT-ITEM(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE 0 TO PL-SNEAKING(WS-ROW)
     MOVE SPACES TO WS-TEXT
     IF MN-WINDOW(WS-ROW) > 0
         STRING FUNCTION TRIM(WS-KEY) " then open" DELIMITED BY SIZE INTO WS-TEXT
     ELSE
         STRING FUNCTION TRIM(WS-KEY) " then closed" DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     MOVE "closed then open" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station stonecutter valid: the menu is valid while the block stands and is not valid when the block is gone" TO TL-CASE
     CALL "MENU-STILL-VALID" USING WS-ROW WS-N
     MOVE WS-N TO WS-E1
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "MENU-STILL-VALID" USING WS-ROW WS-N
     MOVE WS-N TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "stands " FUNCTION TRIM(WS-E1) " gone " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "stands 1 gone 0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     GOBACK.

 LOAD-RECIPES.
     MOVE 4 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2) RC-ROW(3) RC-ROW(4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO RR-ING(WS-I, 1)
         MOVE 18 TO RR-SERIALIZER(WS-I)
     END-PERFORM
     MOVE "minecraft:stone" TO RR-ING(1, 1)
     MOVE "minecraft:stone_bricks" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE "minecraft:stone" TO RR-ING(2, 1)
     MOVE "minecraft:stone_slab" TO RR-RESULT-ID(2)
     MOVE 2 TO RR-RESULT-COUNT(2)
     MOVE "minecraft:stone" TO RR-ING(3, 1)
     MOVE "minecraft:stone_stairs" TO RR-RESULT-ID(3)
     MOVE 1 TO RR-RESULT-COUNT(3)
     MOVE "minecraft:cobblestone" TO RR-ING(4, 1)
     MOVE "minecraft:cobblestone_slab" TO RR-RESULT-ID(4)
     MOVE 2 TO RR-RESULT-COUNT(4).

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE-BLOCK
         MOVE 0 TO WS-STATE2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-S = WS-BY + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-BZ WS-STATE2
         END-PERFORM
     END-PERFORM.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-STATION-STONECUTTER.

 COPY CORETEST.
 COPY BETEST.
