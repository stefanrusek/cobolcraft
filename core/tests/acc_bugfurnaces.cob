*> Acceptance test, lane bugfurnaces (operator report of try18: "blast furnace and smoker aren't interactable"; docs/protocol/31-block-entities-2 section 3,
*> 40-menus-2 section 2, 05a 0x3B Open Screen, 0x13 Container Set Data, 24 recipes): a superflat world with the standard content set (CC_GENERATED_DIR; skipped as a
*> pass without it). For each of the furnace, the blast furnace and the smoker: placing it through Use Item On makes a block entity of the right type; Use Item On with an
*> empty hand sends Open Screen with the kind's menu type (furnace 14, blast furnace 10, smoker 22) and three own slots; the kind's ingredient and coal shift-clicked into
*> the input and fuel slots cook (furnace 200 ticks, blast furnace and smoker 100) into the right result and light the block through a Block Update; an ingredient of
*> another kind (beef in the blast furnace, raw iron in the smoker) is not accepted by the input slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFURNACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY CMENU.
 COPY BESTATE.
 COPY PLAYPKT.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-IDS                 PIC X(512).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-SCREENS             BINARY-LONG.
 01 WS-SCREEN-ID           BINARY-LONG.
 01 WS-SCREEN-TYPE         BINARY-LONG.
 01 WS-UPDATES             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-CLICK               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BDIR                BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-ING                 BINARY-LONG.
 01 WS-WRONG               BINARY-LONG.
 01 WS-FUEL                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE2               PIC 99.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-YES                 PIC X(3).
 01 WS-FAST BINARY-LONG.
 01 WS-PASS                PIC 9.
 01 WS-DSPEED-X            BINARY-LONG.
 01 WS-SURVEY.
    05 FILLER PIC X(26) VALUE "furnace                 14".
    05 FILLER PIC X(26) VALUE "blast_furnace           10".
    05 FILLER PIC X(26) VALUE "smoker                  22".
    05 FILLER PIC X(26) VALUE "barrel                  02".
    05 FILLER PIC X(26) VALUE "chest                   02".
    05 FILLER PIC X(26) VALUE "trapped_chest           02".
    05 FILLER PIC X(26) VALUE "ender_chest             02".
    05 FILLER PIC X(26) VALUE "hopper                  16".
    05 FILLER PIC X(26) VALUE "dropper                 06".
    05 FILLER PIC X(26) VALUE "dispenser               06".
    05 FILLER PIC X(26) VALUE "shulker_box             20".
    05 FILLER PIC X(26) VALUE "crafter                 99".
    05 FILLER PIC X(26) VALUE "brewing_stand           11".
    05 FILLER PIC X(26) VALUE "crafting_table          12".
    05 FILLER PIC X(26) VALUE "loom                    18".
    05 FILLER PIC X(26) VALUE "stonecutter             24".
    05 FILLER PIC X(26) VALUE "grindstone              15".
    05 FILLER PIC X(26) VALUE "smithing_table          21".
    05 FILLER PIC X(26) VALUE "cartography_table       23".
    05 FILLER PIC X(26) VALUE "anvil                   08".
    05 FILLER PIC X(26) VALUE "beacon                  99".
    05 FILLER PIC X(26) VALUE "enchanting_table        13".
 01 FILLER REDEFINES WS-SURVEY.
    05 WS-SV-ROW OCCURS 22 TIMES.
       10 WS-SV-KEY           PIC X(24).
       10 WS-SV-TYPE          PIC 99.
 01 WS-DBURN BINARY-LONG.
 01 WS-DSPEED FLOAT-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-FURNACES.
    05 FILLER PIC X(48) VALUE "furnace".
    05 FILLER PIC X(48) VALUE "blast_furnace".
    05 FILLER PIC X(48) VALUE "smoker".
 01 FILLER REDEFINES WS-FURNACES.
    05 WS-FURNACE-KEY      PIC X(48) OCCURS 3 TIMES.
 01 WS-INGREDIENTS.
    05 FILLER PIC X(48) VALUE "raw_iron".
    05 FILLER PIC X(48) VALUE "raw_iron".
    05 FILLER PIC X(48) VALUE "beef".
 01 FILLER REDEFINES WS-INGREDIENTS.
    05 WS-INGREDIENT-KEY   PIC X(48) OCCURS 3 TIMES.
 01 WS-RESULTS.
    05 FILLER PIC X(48) VALUE "iron_ingot".
    05 FILLER PIC X(48) VALUE "iron_ingot".
    05 FILLER PIC X(48) VALUE "cooked_beef".
 01 FILLER REDEFINES WS-RESULTS.
    05 WS-RESULT-KEY       PIC X(48) OCCURS 3 TIMES.
 01 WS-WRONGS.
    05 FILLER PIC X(48) VALUE "dirt".
    05 FILLER PIC X(48) VALUE "beef".
    05 FILLER PIC X(48) VALUE "raw_iron".
 01 FILLER REDEFINES WS-WRONGS.
    05 WS-WRONG-KEY        PIC X(48) OCCURS 3 TIMES.
 01 WS-MENU-TYPES.
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 99 VALUE 22.
 01 FILLER REDEFINES WS-MENU-TYPES.
    05 WS-MENU-TYPE        PIC 99 OCCURS 3 TIMES.
 01 WS-BE-TYPES.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC 99 VALUE 28.
    05 FILLER PIC 99 VALUE 27.
 01 FILLER REDEFINES WS-BE-TYPES.
    05 WS-BE-TYPE          PIC 99 OCCURS 3 TIMES.
 01 WS-COOK-TIMES.
    05 FILLER PIC 999 VALUE 200.
    05 FILLER PIC 999 VALUE 100.
    05 FILLER PIC 999 VALUE 100.
 01 FILLER REDEFINES WS-COOK-TIMES.
    05 WS-COOK-TIME        PIC 999 OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugfurnaces no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Furnaces" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 9.5
     MOVE 180 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     PERFORM SCAN

     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         PERFORM ONE-FURNACE
     END-PERFORM
     PERFORM FUEL-PROVIDERS
     PERFORM SURVEY
     STOP RUN.

*> The shipped fuel providers (31-2 section 3.3): coal burns 1600 ticks and cooks at speed 1.0 in a furnace, burns 800 ticks and cooks at speed 2.0 in a smoker or a blast furnace.
 FUEL-PROVIDERS.
     MOVE "coal" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-FUEL
     MOVE 0 TO WS-FAST
     CALL "FURN-FUEL" USING WS-FUEL WS-FAST WS-DBURN WS-DSPEED
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "burn 1600 speed 10" TO TL-EXPECTED
     MOVE WS-DBURN TO WS-EDIT
     COMPUTE WS-DSPEED-X = WS-DSPEED * 10
     MOVE WS-DSPEED-X TO WS-EDIT2
     STRING "burn " FUNCTION TRIM(WS-EDIT) " speed " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance bugfurnaces: coal in a furnace burns 1600 ticks at speed 1.0" TO WS-CASE
     PERFORM CHECK-T
     MOVE 1 TO WS-FAST
     CALL "FURN-FUEL" USING WS-FUEL WS-FAST WS-DBURN WS-DSPEED
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "burn 800 speed 20" TO TL-EXPECTED
     MOVE WS-DBURN TO WS-EDIT
     COMPUTE WS-DSPEED-X = WS-DSPEED * 10
     MOVE WS-DSPEED-X TO WS-EDIT2
     STRING "burn " FUNCTION TRIM(WS-EDIT) " speed " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance bugfurnaces: coal in a smoker or a blast furnace burns 800 ticks at speed 2.0 (the speed provider is a context_float_provider)" TO WS-CASE
     PERFORM CHECK-T.

*> Every block that opens a menu, placed by WORLD-SET-BLOCK (pass 1) and as a generated block that has no block entity (pass 2: a structure of the world generator writes block states only),
*> then right-clicked with an empty hand: one Open Screen of the menu type of 46 section 9 (menu), or none (99) for a block that opens nothing yet: the crafter and the beacon
*> have their menu rules (40-2, 40-5) but no live window; the table says 99 for them and changes with the wiring (the brewing stand, loom and cartography table are wired).
 SURVEY.
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 22
             PERFORM SURVEY-ONE
         END-PERFORM
     END-PERFORM.

 SURVEY-ONE.
     MOVE WS-SV-KEY(WS-K) TO WS-KEY
     PERFORM FIND-STATE
     COMPUTE WS-FX = WS-BX + 3
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-BZ + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     IF WS-PASS = 2
         CALL "BE-FIND" USING WS-DIM WS-FX WS-FY WS-FZ WS-BE
         IF WS-BE > 0
             MOVE 0 TO BE-USED(WS-BE)
         END-IF
     END-IF
     COMPUTE PL-X(WS-PLAYER) = WS-FX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-FZ + 3.5
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 1 TO WS-FACE
     ADD 1 TO WS-SEQ
     PERFORM SCAN
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: right-clicking a " FUNCTION TRIM(WS-SV-KEY(WS-K)) " (pass " WS-PASS ") opens menu type " WS-SV-TYPE(WS-K)
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-SV-TYPE(WS-K) TO WS-EXPECT
     MOVE 99 TO WS-OBSERVE
     IF WS-SCREENS = 1
         MOVE WS-SCREEN-TYPE TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     IF MN-WINDOW(WS-PLAYER) > 0
         CALL "TEST-CLOSE-WIN" USING WS-CONN
         PERFORM SCAN
     END-IF
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR.

*> One kind (WS-K): place, open, load, cook, wrong ingredient.
 ONE-FURNACE.
     MOVE WS-FURNACE-KEY(WS-K) TO WS-KEY
     MOVE WS-KEY TO WS-KEY112
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-BLOCK
     COMPUTE WS-FX = WS-BX + 2 + 3 * WS-K
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-BZ + 6
*>   Place it on the stone floor with the item in the main hand.
     PERFORM HOLD-ITEM
     MOVE 1 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FLOOR WS-FZ WS-FACE WS-SEQ
     PERFORM SCAN
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: a " FUNCTION TRIM(WS-KEY) " item placed through Use Item On puts the " FUNCTION TRIM(WS-KEY) " block there"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-KEY)
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "BE-FIND" USING WS-DIM WS-FX WS-FY WS-FZ WS-BE
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: the placed " FUNCTION TRIM(WS-KEY) " has a block entity of type " WS-BE-TYPE(WS-K) " (31-1 table)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-BE-TYPE(WS-K) TO WS-EXPECT
     MOVE -1 TO WS-OBSERVE
     IF WS-BE > 0
         MOVE BE-TYPE(WS-BE) TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   Use Item On with an empty hand opens the kind's menu.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 5 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: an empty-hand Use Item On the " FUNCTION TRIM(WS-KEY) " sends one Open Screen (0x3B) of menu type "
         WS-MENU-TYPE(WS-K) DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "screens 1 type " WS-MENU-TYPE(WS-K) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-SCREENS TO WS-EDIT
     MOVE WS-SCREEN-TYPE TO WS-TYPE2
     STRING "screens " FUNCTION TRIM(WS-EDIT) " type " WS-TYPE2 DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "acceptance bugfurnaces: the menu has the furnace container's three own slots" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE MN-CSIZE(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N

*>   The kind's ingredient and coal are shift-clicked from the hotbar; an ingredient of another kind is not accepted by the input slot.
     CALL "BE-FIND" USING WS-DIM WS-FX WS-FY WS-FZ WS-BE
     MOVE WS-INGREDIENT-KEY(WS-K) TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ING
     MOVE WS-WRONG-KEY(WS-K) TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-WRONG
     MOVE "coal" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-FUEL
     MOVE WS-RESULT-KEY(WS-K) TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-RESULT
     MOVE WS-WRONG TO PL-SLOT-ITEM(WS-PLAYER, 7)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 7)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 7)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-CLICK
     MOVE 36 TO WS-SLOT
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-SLOT WS-BUTTON WS-CLICK
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: " FUNCTION TRIM(WS-WRONG-KEY(WS-K)) " is no ingredient of the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K))
         ": a shift-click leaves its input slot empty" DELIMITED BY SIZE INTO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 7)
     MOVE WS-ING TO PL-SLOT-ITEM(WS-PLAYER, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 5)
     MOVE WS-FUEL TO PL-SLOT-ITEM(WS-PLAYER, 6)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 6)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 6)
     MOVE 34 TO WS-SLOT
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-SLOT WS-BUTTON WS-CLICK
     MOVE 35 TO WS-SLOT
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-SLOT WS-BUTTON WS-CLICK
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: shift-clicking " FUNCTION TRIM(WS-INGREDIENT-KEY(WS-K)) " and coal fills the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K))
         " input (3) and fuel (2) slots" DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "input 3 fuel 2" TO TL-EXPECTED
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-EDIT
     STRING "input " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " fuel " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

*>   The first tick lights the block (a Block Update), the result comes after the kind's cooking time.
     PERFORM SCAN
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM SCAN
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-BDIR WS-BTYPE WS-FLAG
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: one tick lights the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K)) " (lit property true) and sends a Block Update (0x08)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "lit 1 updates 1" TO TL-EXPECTED
     MOVE WS-FLAG TO WS-EDIT
     MOVE WS-UPDATES TO WS-EDIT2
     STRING "lit " FUNCTION TRIM(WS-EDIT) " updates " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     COMPUTE WS-TICKS = WS-COOK-TIME(WS-K) - 2
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K)) " has no result before " WS-COOK-TIME(WS-K) " ticks"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: after " WS-COOK-TIME(WS-K) " ticks the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K)) " holds one "
         FUNCTION TRIM(WS-RESULT-KEY(WS-K)) " in its result slot and two ingredients are left" DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "result 1 yes input 2" TO TL-EXPECTED
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-EDIT
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-EDIT2
     IF BE-SLOT-ITEM(WS-BE, 3) = WS-RESULT
         MOVE "yes" TO WS-YES
     ELSE
         MOVE "no" TO WS-YES
     END-IF
     STRING "result " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-YES) " input " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

*>   Taking the result gives the recipes used their experience (31-2 section 3.6): ten uses of the recipe the furnace cooked (its RecipesUsed row was written by the cook above)
*>   leave orbs worth about ten times its experience.
     MOVE 10 TO BE-F-USED-COUNT(WS-BE, 1)
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 2 TO WS-SLOT
     MOVE 0 TO WS-CLICK
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-SLOT WS-BUTTON WS-CLICK
     PERFORM COUNT-ORBS
     MOVE SPACES TO WS-CASE
     STRING "acceptance bugfurnaces: taking the " FUNCTION TRIM(WS-RESULT-KEY(WS-K)) " from the " FUNCTION TRIM(WS-FURNACE-KEY(WS-K))
         " gives it to the cursor and drops experience orbs" DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "cursor 1 xp yes" TO TL-EXPECTED
     MOVE PL-CARRIED-COUNT(WS-PLAYER) TO WS-EDIT
     IF WS-ORBS > 0
         MOVE "yes" TO WS-YES
     ELSE
         MOVE "no" TO WS-YES
     END-IF
     STRING "cursor " FUNCTION TRIM(WS-EDIT) " xp " FUNCTION TRIM(WS-YES) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 1) BE-SLOT-COUNT(WS-BE, 2) BE-SLOT-COUNT(WS-BE, 3).

*> WS-ORBS: the experience orbs of the world and their summed value.
 COUNT-ORBS.
     MOVE 0 TO WS-ORBS
     CALL "XP-ORB-TYPE" USING WS-ORB-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             COMPUTE WS-ORBS = WS-ORBS + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
         END-IF
     END-PERFORM.

*> Puts five of the item WS-KEY112 in the first hotbar slot and selects it.
 HOLD-ITEM.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

*> Drains what Alice was sent: WS-IDS the packet ids in order, WS-SCREENS the Open Screen packets (container id and menu type of the last).
 SCAN.
     MOVE SPACES TO WS-IDS
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-SCREENS WS-SCREEN-ID WS-SCREEN-TYPE WS-UPDATES
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
             END-IF
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
             IF WS-PACKET-ID = 60
                 ADD 1 TO WS-SCREENS
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-SCREEN-ID
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-SCREEN-TYPE
             END-IF
             IF WS-PACKET-ID = 8
                 ADD 1 TO WS-UPDATES
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

*> WS-STATE: the default state of the block WS-KEY (a key without namespace in the generated set), 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-STATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-T.
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGFURNACES.
 COPY CORETEST.
 COPY BETEST.
