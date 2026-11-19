*> Acceptance test, lane bugchestopen (operator report on try19: "chests can only be opened if there is no solid block above them, but a chest on top
*> of a chest makes the bottom chest unusable. Also copper chests do not open"; docs/protocol/31-block-entities-1 sections 3.1 and 10 (ChestBlock.isChestBlockedAt:
*> the block above is a redstone conductor, or a cat in a sitting pose has its body in the box above), 30-redstone-1 section 2.4 (a conductor is a block whose
*> collision shape is a full cube, less the never list and plus the always list), 40-menus-1 section 3 (a chest is generic_9x3, a double chest generic_9x6)):
*> a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). Alice uses
*> each chest on its top face through the real Use Item On packet. A chest, trapped chest or ender chest under a chest, slab, stairs, glass or leaves opens;
*> under stone it stays shut; a double chest is shut when either half has a conductor above it and opens with a chest above a half; a sitting cat above a chest
*> keeps it shut and a standing cat, or one two cells away, does not; the eight copper chest blocks open as 27-slot menus (single) or 54-slot menus (double) by
*> the same rules.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGCHESTOPEN-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-IID                 BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-EROW                PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 200.
 01 WS-Y1                  BINARY-LONG VALUE 201.
 01 WS-Y2                  BINARY-LONG VALUE 202.
 01 WS-Y3                  BINARY-LONG VALUE 203.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LOWER               PIC X(48).
 01 WS-UPPER               PIC X(48).
 01 WS-DOUBLE              BINARY-LONG.
 01 WS-ABOVE-HALF          BINARY-LONG.
 01 WS-CAT-MODE            BINARY-LONG.
 01 WS-CAT-TYPE            BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-OPEN                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-MTYPE               BINARY-LONG.
 01 WS-LABEL               PIC X(64).
 01 WS-COPPERS.
    05 FILLER              PIC X(48) VALUE "copper_chest".
    05 FILLER              PIC X(48) VALUE "exposed_copper_chest".
    05 FILLER              PIC X(48) VALUE "weathered_copper_chest".
    05 FILLER              PIC X(48) VALUE "oxidized_copper_chest".
    05 FILLER              PIC X(48) VALUE "waxed_copper_chest".
    05 FILLER              PIC X(48) VALUE "waxed_exposed_copper_chest".
    05 FILLER              PIC X(48) VALUE "waxed_weathered_copper_chest".
    05 FILLER              PIC X(48) VALUE "waxed_oxidized_copper_chest".
 01 FILLER REDEFINES WS-COPPERS.
    05 WS-COPPER           PIC X(48) OCCURS 8 TIMES.
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
         MOVE "acceptance bugchestopen standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Chests" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE 0 TO PL-HELD(WS-ROW)
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(PL-ENTITY-ROW(WS-ROW))) + 3
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(PL-ENTITY-ROW(WS-ROW))) + 3
     COMPUTE WS-X2 = WS-X + 1
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STONE
     MOVE "T" TO TL-MODE

*>   Single chests, trapped chests and ender chests under each kind of block above.
     MOVE 0 TO WS-DOUBLE WS-CAT-MODE WS-ABOVE-HALF
     MOVE "chest" TO WS-LOWER
     MOVE "chest" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under a chest opens" TO WS-LABEL
     MOVE "open 1 size 27 type 2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "stone" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under stone stays shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "oak_slab" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under a slab opens" TO WS-LABEL
     MOVE "open 1 size 27 type 2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "glass" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under glass opens" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "oak_leaves" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under leaves opens" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "oak_stairs" TO WS-UPPER
     MOVE "acceptance bugchestopen chest under stairs opens" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE SPACES TO WS-UPPER
     MOVE "acceptance bugchestopen chest with air above opens" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "trapped_chest" TO WS-LOWER
     MOVE "chest" TO WS-UPPER
     MOVE "acceptance bugchestopen trapped chest under a chest opens" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "stone" TO WS-UPPER
     MOVE "acceptance bugchestopen trapped chest under stone stays shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "ender_chest" TO WS-LOWER
     MOVE "chest" TO WS-UPPER
     MOVE "acceptance bugchestopen ender chest under a chest opens" TO WS-LABEL
     MOVE "open 1 size 27 type 2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "stone" TO WS-UPPER
     MOVE "acceptance bugchestopen ender chest under stone stays shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE

*>   Double chests: either half decides.
     MOVE 1 TO WS-DOUBLE
     MOVE "chest" TO WS-LOWER
     MOVE "chest" TO WS-UPPER
     MOVE 1 TO WS-ABOVE-HALF
     MOVE "acceptance bugchestopen double chest with a chest above one half opens as 54 slots" TO WS-LABEL
     MOVE "open 1 size 54 type 5" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 2 TO WS-ABOVE-HALF
     MOVE "acceptance bugchestopen double chest with a chest above the other half opens as 54 slots" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "stone" TO WS-UPPER
     MOVE 1 TO WS-ABOVE-HALF
     MOVE "acceptance bugchestopen double chest with stone above the first half stays shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 2 TO WS-ABOVE-HALF
     MOVE "acceptance bugchestopen double chest with stone above the second half stays shut" TO WS-LABEL
     PERFORM RUN-CASE

*>   Copper chests: all eight blocks, single and double.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 8
         MOVE WS-COPPER(WS-J) TO WS-LOWER
         MOVE 0 TO WS-DOUBLE WS-ABOVE-HALF
         MOVE SPACES TO WS-UPPER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance bugchestopen " FUNCTION TRIM(WS-LOWER) " opens as a 27-slot container" DELIMITED BY SIZE INTO WS-LABEL
         MOVE "open 1 size 27 type 2" TO TL-EXPECTED
         PERFORM RUN-CASE
         MOVE "chest" TO WS-UPPER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance bugchestopen " FUNCTION TRIM(WS-LOWER) " under a chest opens" DELIMITED BY SIZE INTO WS-LABEL
         PERFORM RUN-CASE
         MOVE "stone" TO WS-UPPER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance bugchestopen " FUNCTION TRIM(WS-LOWER) " under stone stays shut" DELIMITED BY SIZE INTO WS-LABEL
         MOVE "open 0" TO TL-EXPECTED
         PERFORM RUN-CASE
         MOVE 1 TO WS-DOUBLE
         MOVE 2 TO WS-ABOVE-HALF
         MOVE "chest" TO WS-UPPER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance bugchestopen double " FUNCTION TRIM(WS-LOWER) " with a chest above a half opens as 54 slots"
             DELIMITED BY SIZE INTO WS-LABEL
         MOVE "open 1 size 54 type 5" TO TL-EXPECTED
         PERFORM RUN-CASE
         MOVE "stone" TO WS-UPPER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance bugchestopen double " FUNCTION TRIM(WS-LOWER) " with stone above a half stays shut" DELIMITED BY SIZE INTO WS-LABEL
         MOVE "open 0" TO TL-EXPECTED
         PERFORM RUN-CASE
     END-PERFORM

*>   A cat in the sitting pose in the cell above a chest keeps it shut.
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CAT-TYPE WS-EROW WS-STATUS
     MOVE 0 TO WS-DOUBLE WS-ABOVE-HALF
     MOVE SPACES TO WS-UPPER
     MOVE "chest" TO WS-LOWER
     MOVE 1 TO WS-CAT-MODE
     MOVE "acceptance bugchestopen a sitting cat above a chest keeps it shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "ender_chest" TO WS-LOWER
     MOVE "acceptance bugchestopen a sitting cat above an ender chest keeps it shut" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "copper_chest" TO WS-LOWER
     MOVE "acceptance bugchestopen a sitting cat above a copper chest keeps it shut" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE "chest" TO WS-LOWER
     MOVE 2 TO WS-CAT-MODE
     MOVE "acceptance bugchestopen a standing cat above a chest does not keep it shut" TO WS-LABEL
     MOVE "open 1 size 27 type 2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 3 TO WS-CAT-MODE
     MOVE "acceptance bugchestopen a sitting cat two cells away does not keep a chest shut" TO WS-LABEL
     PERFORM RUN-CASE
     MOVE 1 TO WS-CAT-MODE
     MOVE 1 TO WS-DOUBLE
     MOVE 2 TO WS-ABOVE-HALF
     MOVE "acceptance bugchestopen a sitting cat above one half of a double chest keeps both shut" TO WS-LABEL
     MOVE "open 0" TO TL-EXPECTED
     PERFORM RUN-CASE
     STOP RUN.

*> One case: the floor at y 200 under WS-X (and WS-X2 for a double), the lower chest placed by Use Item On (twice for a double chest: the second one is
*> placed at WS-X2 and joins the first), the upper block (WS-UPPER, spaces none) at y 202 above the half WS-ABOVE-HALF (0 above the single), the cat of
*> WS-CAT-MODE (0 none, 1 sitting above, 2 standing above, 3 sitting two cells away), then Use Item On the chest at WS-X.
 RUN-CASE.
     PERFORM CLEAR-CELLS
     MOVE SPACES TO WS-KEY
     MOVE WS-LOWER TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     IF WS-DOUBLE = 1
         ADD 1 TO WS-SEQ
         CALL "TEST-USE-ON" USING WS-CONN WS-X2 WS-Y WS-Z WS-FACE WS-SEQ
     END-IF
     IF WS-UPPER NOT = SPACES
         MOVE SPACES TO WS-KEY
         MOVE WS-UPPER TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
         MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
         IF WS-ABOVE-HALF = 2
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y2 WS-Z WS-STATE
         ELSE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-STATE
         END-IF
     END-IF
     IF WS-CAT-MODE > 0
         COMPUTE WS-FX = WS-X + 0.5
         COMPUTE WS-FY = WS-Y2
         COMPUTE WS-FZ = WS-Z + 0.5
         IF WS-ABOVE-HALF = 2
             COMPUTE WS-FX = WS-X2 + 0.5
         END-IF
         IF WS-CAT-MODE = 3
             COMPUTE WS-FX = WS-X + 2.5
         END-IF
         CALL "MOB-SPAWN" USING WS-DIM WS-CAT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-CAT
         MOVE 10 TO EN-HEALTH(WS-CAT)
         MOVE 1 TO EN-TAMED(WS-CAT)
         MOVE PL-UUID(WS-ROW) TO EN-OWNER-UUID(WS-CAT)
         IF WS-CAT-MODE = 2
             MOVE 0 TO EN-SIT(WS-CAT)
         ELSE
             MOVE 1 TO EN-SIT(WS-CAT)
         END-IF
     END-IF
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y1 WS-Z WS-FACE WS-SEQ
     MOVE 0 TO WS-OPEN WS-SIZE WS-MTYPE
     IF MN-WINDOW(WS-ROW) > 0
         MOVE 1 TO WS-OPEN
         MOVE MN-CSIZE(WS-ROW) TO WS-SIZE
         MOVE MN-TYPE(WS-ROW) TO WS-MTYPE
         CALL "MENU-CLOSE" USING WS-CONN
     END-IF
     MOVE WS-OPEN TO WS-E1
     MOVE WS-SIZE TO WS-E2
     MOVE WS-MTYPE TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     IF WS-OPEN = 1
         STRING "open 1 size " FUNCTION TRIM(WS-E2) " type " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         MOVE "open 0" TO TL-OBSERVED
     END-IF
     MOVE WS-LABEL TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A stone floor at y 200 under both cells, air above (blocks changed through BLOCK-CHANGE so their entities go), no mobs, nothing open.
 CLEAR-CELLS.
     IF MN-WINDOW(WS-ROW) > 0
         CALL "MENU-CLOSE" USING WS-CONN
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         COMPUTE WS-J = WS-X + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-J WS-Y WS-Z WS-STONE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-J WS-Y1 WS-Z WS-VOID
         CALL "BLOCK-CHANGE" USING WS-DIM WS-J WS-Y2 WS-Z WS-VOID
         CALL "BLOCK-CHANGE" USING WS-DIM WS-J WS-Y3 WS-Z WS-VOID
     END-PERFORM
     COMPUTE WS-J = WS-X + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-J WS-Y WS-Z WS-STONE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-J WS-Y1 WS-Z WS-VOID
     CALL "BLOCK-CHANGE" USING WS-DIM WS-J WS-Y2 WS-Z WS-VOID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-PLAYER(WS-I) = 0
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGCHESTOPEN-STANDARD.

 COPY CORETEST.
