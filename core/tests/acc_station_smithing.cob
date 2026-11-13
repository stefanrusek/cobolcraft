*> Acceptance test, the smithing table menu through the real play path (docs/protocol/40-menus-3 section 5; 27 section 3.3; 002-lane-stations T5202): Use Item On opens menu
*> type 21 (4 own slots), the template, base and addition slots take the items of the smithing recipes, the first matching recipe makes the result with the base patch, taking it
*> uses one of each input, shift click moves it, the error flag (data slot 0) is set with three full inputs and no recipe, a recipe with an absent ingredient needs an empty slot,
*> closing returns the inputs. Standard tables with two smithing_transform recipes written into the store here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-STATION-SMITHING.
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
 01 WS-TABLE               BINARY-LONG.
 01 WS-TEMPLATE            BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-NSWORD              BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-NPICK               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
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
     MOVE "smithing_table" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-TABLE
     MOVE "netherite_upgrade_smithing_template" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-TEMPLATE
     MOVE "diamond_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SWORD
     MOVE "netherite_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-NSWORD
     MOVE "netherite_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
     MOVE "diamond_pickaxe" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PICK
     MOVE "netherite_pickaxe" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-NPICK
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
     PERFORM LOAD-RECIPES
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM

     MOVE "acceptance station smithing sets: the template, base and addition sets take their ingredients of the recipes, nothing else, item 0 never" TO TL-CASE
     MOVE 1 TO WS-SET
     CALL "MENU-SMITH-SET" USING WS-SET WS-TEMPLATE WS-OK
     MOVE WS-OK TO WS-E1
     MOVE 2 TO WS-SET
     CALL "MENU-SMITH-SET" USING WS-SET WS-SWORD WS-OK
     MOVE WS-OK TO WS-E2
     MOVE 3 TO WS-SET
     CALL "MENU-SMITH-SET" USING WS-SET WS-INGOT WS-OK
     MOVE WS-OK TO WS-E3
     MOVE 1 TO WS-SET
     CALL "MENU-SMITH-SET" USING WS-SET WS-INGOT WS-OK
     MOVE WS-OK TO WS-E4
     MOVE 0 TO WS-N
     MOVE 2 TO WS-SET
     CALL "MENU-SMITH-SET" USING WS-SET WS-N WS-OK
     MOVE WS-OK TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 1 1 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE WS-TABLE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE "acceptance station smithing open: Use Item On opens menu 21 with 4 own slots, the result is slot 3" TO TL-CASE
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-WRES(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 21 size 4 result 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing inputs: shift clicks send the template, the damaged sword and the ingot each to its own slot, the result is a netherite "
         & "sword that keeps the base's patch" TO TL-CASE
     MOVE 50 TO WS-DMG
     MOVE 0 TO WS-VAR
     CALL "SP-SET-DAMAGE" USING WS-VAR WS-DMG
     MOVE WS-TEMPLATE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-SWORD TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-VAR TO PL-SLOT-VAR(WS-ROW, 2)
     MOVE WS-INGOT TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 3)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     PERFORM VARYING WS-S FROM 31 BY 1 UNTIL WS-S > 33
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     END-PERFORM
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E3
     IF MN-RESULT-ITEM(WS-ROW) = WS-NSWORD
         MOVE 1 TO WS-E4
     ELSE
         MOVE 0 TO WS-E4
     END-IF
     IF MN-RESULT-VAR(WS-ROW) = WS-VAR
         MOVE 1 TO WS-E5
     ELSE
         MOVE 0 TO WS-E5
     END-IF
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) " result " FUNCTION TRIM(WS-E4) " patch " FUNCTION TRIM(WS-E5)
         " flag " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "111 result 1 patch 1 flag 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing take: picking the result up gives the sword on the cursor with the base's patch, one of each input is used up, the "
         & "result is empty again" TO TL-CASE
     MOVE 0 TO WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     IF PL-CARRIED-VAR(WS-ROW) = WS-VAR
         MOVE 1 TO WS-E2
     ELSE
         MOVE 0 TO WS-E2
     END-IF
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E4
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E5
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " patch " FUNCTION TRIM(WS-E2) " inputs " FUNCTION TRIM(WS-E3) FUNCTION TRIM(WS-E4)
         FUNCTION TRIM(WS-E5) " result " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 1 patch 1 inputs 000 result 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW)

     MOVE "acceptance station smithing quick move: a shift click on the result moves it to the inventory and uses up the inputs" TO TL-CASE
     MOVE WS-TEMPLATE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE WS-SWORD TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE 0 TO MN-WSLOT-VAR(WS-ROW, 2)
     MOVE WS-INGOT TO MN-WSLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE 1 TO WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-NSWORD
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "swords " FUNCTION TRIM(WS-E1) " template " FUNCTION TRIM(WS-E2) " base " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "swords 1 template 1 base 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing error: a recipe that wants an empty addition slot does not match with an addition, the three full inputs with no "
         & "result set the error flag (data slot 0), one input fewer clears it" TO TL-CASE
     MOVE WS-PICK TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE WS-INGOT TO MN-WSLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 3) MN-WSLOT-ITEM(WS-ROW, 3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E3
     IF MN-RESULT-ITEM(WS-ROW) = WS-NPICK
         MOVE 1 TO WS-E4
     ELSE
         MOVE 0 TO WS-E4
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "flag " FUNCTION TRIM(WS-E1) " result " FUNCTION TRIM(WS-E2) " then flag " FUNCTION TRIM(WS-E3) " pickaxe " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "flag 1 result 0 then flag 0 pickaxe 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing place: a foreign stack is refused by the template slot, a template is taken; a click on the result with an item on the "
         & "cursor places nothing" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-COUNT(WS-ROW, 2) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE WS-DIRT TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO WS-TYPE
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE WS-TEMPLATE TO PL-CARRIED-ITEM(WS-ROW)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "dirt " FUNCTION TRIM(WS-E1) " template " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "dirt 0 template 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing unknown result: a recipe whose result item is unknown makes no result; a shift click on an empty slot does nothing" TO TL-CASE
     MOVE WS-TEMPLATE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE WS-DIRT TO MN-WSLOT-ITEM(WS-ROW, 2) MN-WSLOT-ITEM(WS-ROW, 3)
     MOVE 5 TO MN-WSLOT-COUNT(WS-ROW, 2) MN-WSLOT-COUNT(WS-ROW, 3)
     MOVE 0 TO MN-WSLOT-VAR(WS-ROW, 2)
     MOVE "minecraft:no_such_item" TO RR-RESULT-ID(3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E2
     MOVE "minecraft:netherite_ingot" TO RR-RESULT-ID(3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 8 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE SPACES TO WS-TEXT
     STRING "none " FUNCTION TRIM(WS-E1) " flag " FUNCTION TRIM(WS-E2) " ingots " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "none 0 flag 1 ingots 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance station smithing quick move with no room: one of two ingots fits, the other is dropped, then nothing moves; an input with no room stays" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, WS-I)
         MOVE 64 TO PL-SLOT-COUNT(WS-ROW, WS-I)
         MOVE 0 TO PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-INGOT TO PL-SLOT-ITEM(WS-ROW, 36)
     MOVE 63 TO PL-SLOT-COUNT(WS-ROW, 36)
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-SLOT-COUNT(WS-ROW, 36) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "ingots " FUNCTION TRIM(WS-E1) " template " FUNCTION TRIM(WS-E2) " stays " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "ingots 64 template 4 stays 4" TO TL-EXPECTED
     PERFORM CHECK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I)
     END-PERFORM
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-COUNT(WS-ROW, 2) MN-WSLOT-COUNT(WS-ROW, 3)

     MOVE "acceptance station smithing close: the inputs return to the inventory" TO TL-CASE
     MOVE WS-INGOT TO MN-WSLOT-ITEM(WS-ROW, 3)
     MOVE 3 TO MN-WSLOT-COUNT(WS-ROW, 3)
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-INGOT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E1
     MOVE MN-WINDOW(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "ingots " FUNCTION TRIM(WS-E1) " window " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "ingots 3 window 0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 LOAD-RECIPES.
     MOVE 3 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2) RC-ROW(3)
     MOVE 19 TO RR-SERIALIZER(1) RR-SERIALIZER(2) RR-SERIALIZER(3)
     MOVE "minecraft:netherite_upgrade_smithing_template" TO RR-ING(3, 1)
     MOVE "minecraft:dirt" TO RR-ING(3, 2) RR-ING(3, 3)
     MOVE "minecraft:netherite_ingot" TO RR-RESULT-ID(3)
     MOVE 2 TO RR-RESULT-COUNT(3)
     MOVE "minecraft:netherite_upgrade_smithing_template" TO RR-ING(1, 1)
     MOVE "minecraft:diamond_sword" TO RR-ING(1, 2)
     MOVE "minecraft:netherite_ingot" TO RR-ING(1, 3)
     MOVE "minecraft:netherite_sword" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE "minecraft:netherite_upgrade_smithing_template" TO RR-ING(2, 1)
     MOVE "minecraft:diamond_pickaxe" TO RR-ING(2, 2)
     MOVE SPACES TO RR-ING(2, 3)
     MOVE "minecraft:netherite_pickaxe" TO RR-RESULT-ID(2)
     MOVE 1 TO RR-RESULT-COUNT(2).

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
 END PROGRAM ACC-STATION-SMITHING.

 COPY CORETEST.
 COPY BETEST.
