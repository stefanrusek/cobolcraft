*> Acceptance test, the brewing stand through the real play path (docs/protocol/40-menus-2 section 4, 31-2 section 4, 48 section 7; lane p70c, T23502): the content set is the standard one with the
*> brewing providers (uses 20, speed 1.0) and two brewing recipes in the store (a water bottle with nether wart gives an awkward potion, an awkward one with sugar a swiftness potion).
*> A player places a brewing stand, opens it (family 9, 5 slots, menu type 11), shift-clicks a water bottle, nether wart and blaze powder into their slots (the potion in a bottle slot, the
*> wart in the ingredient slot, the fuel in the fuel slot), the ticks load the fuel, brew for 400 ticks and turn the bottle into an awkward potion; the block shows has_bottle_0; an awkward
*> bottle with nether wart does not brew (the recipe wants a water bottle); the data slots follow brewTime, fuel, totalBrewTime and totalFuel; closing keeps the contents in the stand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-P70C-BREW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CONTENT.
 COPY CTRECIPE.
 COPY CITEMS.
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
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STAND               BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-WART                BINARY-LONG.
 01 WS-BLAZE               BINARY-LONG.
 01 WS-SUGAR               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-WATER-ID            BINARY-LONG.
 01 WS-AWKWARD-ID          BINARY-LONG.
 01 WS-SWIFT-ID            BINARY-LONG.
 01 WS-WATER-VAR           BINARY-LONG.
 01 WS-AWK-VAR             BINARY-LONG.
 01 WS-KEY32               PIC X(32).
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-POT                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-CUSTOM              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK2                 BINARY-LONG.
 01 WS-OK3                 BINARY-LONG.
 01 WS-USES                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-ROWN                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE-SLOT            BINARY-LONG VALUE 1.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-COMMAND             PIC X(4000).
 01 WS-DIRF                PIC X(1100) VALUE "build/brew-fix/t".
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-SAVE-TYPES          PIC X(20000).
 01 WS-SAVE-ROLES          PIC X(64).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     PERFORM SWITCH-CONTENT
     MOVE "stone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "brewing_stand" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STAND
     MOVE "potion" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-POTION
     MOVE "nether_wart" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-WART
     MOVE "blaze_powder" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BLAZE
     MOVE "sugar" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SUGAR
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
     MOVE "water" TO WS-KEY32
     CALL "SC-POTION-ID" USING WS-KEY32 WS-WATER-ID
     MOVE "awkward" TO WS-KEY32
     CALL "SC-POTION-ID" USING WS-KEY32 WS-AWKWARD-ID
     MOVE "swiftness" TO WS-KEY32
     CALL "SC-POTION-ID" USING WS-KEY32 WS-SWIFT-ID
     MOVE 0 TO WS-WATER-VAR WS-AWK-VAR
     CALL "SC-POTION-SET" USING WS-WATER-VAR WS-WATER-ID
     CALL "SC-POTION-SET" USING WS-AWK-VAR WS-AWKWARD-ID
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-STAND TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK

     MOVE "acceptance p70c brew open: Use Item On the stand opens family 9 of 5 own slots, menu type 11, and Open Screen is sent" TO TL-CASE
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-TYPE(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 52"
     MOVE WS-TALLY TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "family " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " type " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "family 9 size 5 type 11" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew shift clicks: the water bottle goes to bottle slot 0, the nether wart to the ingredient slot, the blaze powder to the fuel slot, dirt stays" TO TL-CASE
     MOVE WS-POTION TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-WATER-VAR TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE WS-WART TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-BLAZE TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 3)
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 4)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 4)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     PERFORM VARYING WS-S FROM 5 BY 1 UNTIL WS-S > 8
         COMPUTE WS-I = WS-S + 27
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-I WS-BUTTON WS-TYPE
     END-PERFORM
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "bottle " FUNCTION TRIM(WS-E1) " wart " FUNCTION TRIM(WS-E2) " fuel " FUNCTION TRIM(WS-E3) " bottle2 " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "bottle 1 wart 3 fuel 2 bottle2 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew quick edges: items 0 are no input, reagent or fuel; a click on an empty slot does nothing; blaze powder with a full fuel slot goes nowhere unless it is a reagent, then into the empty ingredient slot" TO TL-CASE
     CALL "BREW-IS-INPUT" USING WS-ZERO WS-OK
     CALL "BREW-IS-REAGENT" USING WS-ZERO WS-OK2
     CALL "BREW-FUEL" USING WS-ZERO WS-USES WS-SPEED
     MOVE WS-OK TO WS-E1
     MOVE WS-OK2 TO WS-E2
     MOVE WS-USES TO WS-E3
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 20 TO WS-I
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-I WS-BUTTON WS-TYPE
     MOVE 64 TO BE-SLOT-COUNT(WS-BE, 5)
     MOVE WS-BLAZE TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 36 TO WS-I
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-I WS-BUTTON WS-TYPE
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO WS-E4
     MOVE 3 TO RC-COUNT
     INITIALIZE RC-ROW(3)
     MOVE 20 TO RR-SERIALIZER(3)
     MOVE "minecraft:potion" TO RR-ING(3, 1)
     MOVE "minecraft:blaze_powder" TO RR-ING(3, 2)
     MOVE "minecraft:potion" TO RR-RESULT-ID(3)
     MOVE "brewing/strength" TO RR-KEY(3)
     MOVE WS-WART TO WS-RVAR
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-RESULT
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 4)
     MOVE 0 TO BE-SLOT-ITEM(WS-BE, 4)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-I WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E5
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO WS-E6
     MOVE WS-RVAR TO BE-SLOT-ITEM(WS-BE, 4)
     MOVE WS-RESULT TO BE-SLOT-COUNT(WS-BE, 4)
     MOVE 2 TO RC-COUNT
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 5)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 5) PL-SLOT-ITEM(WS-ROW, 5)
     MOVE SPACES TO WS-TEXT
     STRING "zeros " FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) " blaze-left " FUNCTION TRIM(WS-E4) " ingredient " FUNCTION TRIM(WS-E5)
         " rest " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "zeros 000 blaze-left 3 ingredient 3 rest 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew close and reopen: the stand keeps its contents when the window closes, the window id moves on and the contents are in the new menu" TO TL-CASE
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     MOVE MN-WINDOW(WS-ROW) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E2
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-E3
     MOVE MN-CFAMILY(WS-ROW) TO WS-E4
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "closed " FUNCTION TRIM(WS-E1) " bottle " FUNCTION TRIM(WS-E2) " reopened " FUNCTION TRIM(WS-E3) " family " FUNCTION TRIM(WS-E4)
         " fuel " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "closed 0 bottle 1 reopened 2 family 9 fuel 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew tick: the first tick loads the fuel (20 uses, one used for the brew, blaze powder 1 left) and starts a brew of 400 ticks; the data slots are sent" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-XI(WS-BE, 1) TO WS-E1
     MOVE BE-XI(WS-BE, 3) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE MN-CDATA(WS-ROW, 1) TO WS-E4
     MOVE MN-CDATA(WS-ROW, 2) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "brew " FUNCTION TRIM(WS-E1) " fuel " FUNCTION TRIM(WS-E2) " blaze " FUNCTION TRIM(WS-E3) " data " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "brew 400 fuel 19 blaze 1 data 400 19" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew result: after 400 more ticks the bottle is an awkward potion, one nether wart is used, the block has has_bottle_0 only" TO TL-CASE
     MOVE 400 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E1
     CALL "SC-POTION-GET" USING BE-SLOT-VAR(WS-BE, 1) WS-POT WS-HAS WS-COLOR WS-CUSTOM
     MOVE WS-POT TO WS-E2
     MOVE WS-AWKWARD-ID TO WS-E3
     MOVE BE-XI(WS-BE, 1) TO WS-E4
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-MASK WS-FLAG
     MOVE WS-MASK TO WS-E5
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-I
     IF WS-POT = WS-AWKWARD-ID
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "wart " FUNCTION TRIM(WS-E1) " potion-ok " FUNCTION TRIM(WS-E6) " brew " FUNCTION TRIM(WS-E4) " mask " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "wart 2 potion-ok 1 brew 0 mask 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew condition: an awkward bottle with nether wart does not brew (the recipe wants a water bottle)" TO TL-CASE
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-XI(WS-BE, 1) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "brew " FUNCTION TRIM(WS-E1) " wart " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "brew 0 wart 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew second recipe: sugar with the awkward bottle brews a swiftness potion in 400 ticks" TO TL-CASE
     MOVE WS-SUGAR TO BE-SLOT-ITEM(WS-BE, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 4)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 4)
     MOVE 401 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "SC-POTION-GET" USING BE-SLOT-VAR(WS-BE, 1) WS-POT WS-HAS WS-COLOR WS-CUSTOM
     MOVE 0 TO WS-I
     IF WS-POT = WS-SWIFT-ID
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "swiftness " FUNCTION TRIM(WS-E1) " sugar " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "swiftness 1 sugar 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c brew slot rules: a potion fits an empty bottle slot only as one item, an item that is no recipe ingredient does not fit slot 3, dirt does not fit the fuel slot" TO TL-CASE
     CALL "MENU-BREW-MAYPLACE" USING WS-ZERO WS-POTION WS-OK
     MOVE 3 TO WS-S
     CALL "MENU-BREW-MAYPLACE" USING WS-S WS-DIRT WS-OK2
     MOVE 4 TO WS-S
     CALL "MENU-BREW-MAYPLACE" USING WS-S WS-DIRT WS-OK3
     MOVE WS-OK TO WS-E1
     MOVE WS-OK2 TO WS-E2
     MOVE WS-OK3 TO WS-E3
     CALL "BREW-FUEL" USING WS-DIRT WS-USES WS-SPEED
     MOVE WS-USES TO WS-E4
     CALL "BREW-FUEL" USING WS-BLAZE WS-USES WS-SPEED
     MOVE WS-USES TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "potion " FUNCTION TRIM(WS-E1) " dirt-slot3 " FUNCTION TRIM(WS-E2) " dirt-fuel " FUNCTION TRIM(WS-E3) " dirt-uses " FUNCTION TRIM(WS-E4)
         " blaze-uses " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "potion 1 dirt-slot3 0 dirt-fuel 0 dirt-uses 0 blaze-uses 20" TO TL-EXPECTED
     PERFORM CHECK

     STOP RUN.

 SWITCH-CONTENT.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/brew-fix 2>/dev/null; rm -rf build/brew-fix; mkdir -p build/brew-fix && cp -R content/tests/fixtures/std "
         "build/brew-fix/t && mkdir -p build/brew-fix/t/vanilla-data/data/minecraft/context_int_provider/brewing && cd build/brew-fix/t/"
         "vanilla-data/data/minecraft/context_int_provider/brewing && printf '20' > uses_default.json && printf '1.0' > speed_default.json"
         X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     CALL "FURN-PROVIDERS-LOAD" USING WS-DIRF
     MOVE 2 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2)
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE "minecraft:potion" TO RR-ING(1, 1)
     MOVE "minecraft:nether_wart" TO RR-ING(1, 2)
     MOVE "minecraft:potion" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE "minecraft:water minecraft:awkward" TO RR-EXTRA(1)
     MOVE "brewing/awkward" TO RR-KEY(1)
     MOVE 20 TO RR-SERIALIZER(2)
     MOVE "minecraft:potion" TO RR-ING(2, 1)
     MOVE "minecraft:sugar" TO RR-ING(2, 2)
     MOVE "minecraft:potion" TO RR-RESULT-ID(2)
     MOVE 1 TO RR-RESULT-COUNT(2)
     MOVE "minecraft:awkward minecraft:swiftness" TO RR-EXTRA(2)
     MOVE "brewing/swiftness" TO RR-KEY(2)
     MOVE CORE-ENTITY-TYPES TO WS-SAVE-TYPES
     MOVE CORE-ENTITY-ROLES TO WS-SAVE-ROLES
     CALL "BLOCKS-OPEN"
     CALL "CORE-TABLES-OPEN"
     MOVE WS-SAVE-TYPES TO CORE-ENTITY-TYPES
     MOVE WS-SAVE-ROLES TO CORE-ENTITY-ROLES.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     COMPUTE WS-X0 = WS-BX - 3
     COMPUTE WS-X1 = WS-BX + 3
     COMPUTE WS-Z0 = WS-BZ - 3
     COMPUTE WS-Z1 = WS-BZ + 3
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             MOVE 0 TO WS-STATE2
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
                 COMPUTE WS-S = WS-BY + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-Z WS-STATE2
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-P70C-BREW.

 COPY CORETEST.
 COPY BETEST.
