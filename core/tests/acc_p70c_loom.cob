*> Acceptance test, the loom as a live menu through the real play path (docs/protocol/40-menus-4 section 3; lane p70c, T23500): Use Item On opens family 25 (4 own slots, result 3), shift clicks route
*> a banner, a dye and a pattern item to their slots and refuse other items, the 32 patterns of an empty pattern slot are selectable by button (the result is the banner with the layer), a pattern
*> item selects its one pattern by itself, taking the result uses one banner and one dye and keeps the selection while both remain, a banner of 6 layers gets no result, closing returns the inputs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-P70C-LOOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CONTENT.
 COPY PLAYPKT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-REG-STATUS          BINARY-LONG.
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
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-LOOM                BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-DYE2                BINARY-LONG.
 01 WS-PAT                 BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-TIDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 40 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-WINDOW              BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-DYEID               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PLEN                BINARY-LONG.
 01 WS-PNAME               PIC X(32).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
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
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "loom" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-LOOM
     MOVE "white_banner" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BANNER
     MOVE "red_dye" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DYE
     MOVE "blue_dye" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DYE2
     MOVE "creeper_banner_pattern" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PAT
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
*>   The item tags the loom reads: the 16 dyes and the ten pattern items (the fixture holds none of them).
     MOVE "item" TO WS-REGI
     MOVE WS-DYE TO WS-MEMBER(1)
     MOVE WS-DYE2 TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     MOVE "minecraft:loom_dyes" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE WS-PAT TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:loom_patterns" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-LOOM TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK
     MOVE MN-WINDOW(WS-ROW) TO WS-WINDOW

     MOVE "acceptance p70c loom open: Use Item On the loom opens family 25 of 4 own slots, the result is slot 3, menu type 18, no selection" TO TL-CASE
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-WRES(WS-ROW) TO WS-E3
     MOVE MN-TYPE(WS-ROW) TO WS-E4
     MOVE MN-WSEL(WS-ROW) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "family " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) " type " FUNCTION TRIM(WS-E4)
         " sel " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "family 25 size 4 result 3 type 18 sel -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom quick: shift clicks send the banner to slot 0 and the dye to slot 1, dirt stays in the inventory" TO TL-CASE
     MOVE WS-BANNER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-DYE TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 3)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     PERFORM VARYING WS-S FROM 31 BY 1 UNTIL WS-S > 33
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     END-PERFORM
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E3
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-DIRT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "inputs " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " dirt " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "inputs 3/1/0 dirt 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom list: with a banner and a dye and an empty pattern slot nothing is selected and the result is empty; the data slot is -1" TO TL-CASE
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " result " FUNCTION TRIM(WS-E2) " data " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel -1 result 0 data -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom button: button 5 (stripe_top of the tag order) selects it; the result is one white banner with the layer (stripe_top, red); data slot 0 is sent" TO TL-CASE
     MOVE 5 TO WS-BUTTON
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-WINDOW WS-BUTTON
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "stripe_top" TO WS-PNAME
     MOVE 10 TO WS-PLEN
     CALL "BE3-BANNER-PATTERN" USING WS-PNAME WS-PLEN WS-PATTERN
     MOVE 1 TO WS-N
     CALL "SC-BANNER-NTH" USING MN-RESULT-VAR(WS-ROW) WS-N WS-HANDLE WS-DYEID
     MOVE 0 TO WS-I
     IF WS-HANDLE = WS-PATTERN
         MOVE 1 TO WS-I
     END-IF
     CALL "SC-BANNER-COUNT" USING MN-RESULT-VAR(WS-ROW) WS-N
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE WS-I TO WS-E4
     MOVE WS-DYEID TO WS-E5
     IF MN-RESULT-ITEM(WS-ROW) = WS-BANNER
         MOVE 1 TO WS-E6
     ELSE
         MOVE 0 TO WS-E6
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2) " layers " FUNCTION TRIM(WS-E3) " pattern-ok " FUNCTION TRIM(WS-E4)
         " dye " FUNCTION TRIM(WS-E5) " banner " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel 5 count 1 layers 1 pattern-ok 1 dye 14 banner 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom button: an id past the list changes nothing" TO TL-CASE
     MOVE 32 TO WS-BUTTON
     CALL "TEST-BUTTON-WIN" USING WS-CONN WS-WINDOW WS-BUTTON
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel 5 count 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom take: the result goes to the cursor, one banner and one dye are used (2 banners, no dye left), the selection resets and the result is empty" TO TL-CASE
     MOVE 0 TO WS-BUTTON
     MOVE 0 TO WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE MN-WSEL(WS-ROW) TO WS-E4
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E5
     CALL "SC-BANNER-COUNT" USING PL-CARRIED-VAR(WS-ROW) WS-N
     MOVE WS-N TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " layers " FUNCTION TRIM(WS-E6) " banners " FUNCTION TRIM(WS-E2) " dyes " FUNCTION TRIM(WS-E3)
         " sel " FUNCTION TRIM(WS-E4) " result " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 1 layers 1 banners 2 dyes 0 sel -1 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom pattern item: a creeper pattern item and a second dye give a list of one that selects itself; the result carries the creeper layer in blue" TO TL-CASE
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-VAR(WS-ROW)
     MOVE WS-DYE2 TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-PAT TO PL-SLOT-ITEM(WS-ROW, 4)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 4)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 2) PL-SLOT-VAR(WS-ROW, 4)
     MOVE 1 TO WS-TYPE
     MOVE 31 TO WS-S
     MOVE 1 TO WS-I
     PERFORM VARYING WS-S FROM 32 BY 1 UNTIL WS-S > 34
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     END-PERFORM
     MOVE "creeper" TO WS-PNAME
     MOVE 7 TO WS-PLEN
     CALL "BE3-BANNER-PATTERN" USING WS-PNAME WS-PLEN WS-PATTERN
     MOVE 1 TO WS-N
     CALL "SC-BANNER-NTH" USING MN-RESULT-VAR(WS-ROW) WS-N WS-HANDLE WS-DYEID
     MOVE 0 TO WS-I
     IF WS-HANDLE = WS-PATTERN
         MOVE 1 TO WS-I
     END-IF
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E2
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE WS-I TO WS-E4
     MOVE WS-DYEID TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " pattern-slot " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) " creeper " FUNCTION TRIM(WS-E4)
         " dye " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel 0 pattern-slot 1 result 1 creeper 1 dye 11" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom take keeps the selection: a take uses one banner and one dye, the pattern item stays and the result is made again" TO TL-CASE
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E3
     MOVE MN-WSEL(WS-ROW) TO WS-E4
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "banners " FUNCTION TRIM(WS-E1) " dyes " FUNCTION TRIM(WS-E2) " pattern " FUNCTION TRIM(WS-E3) " sel " FUNCTION TRIM(WS-E4)
         " result " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "banners 1 dyes 1 pattern 1 sel 0 result 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom layer cap: a banner of 6 layers gets no result and no selection" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-DYEID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 4 TO WS-PATTERN
         CALL "SC-BANNER-ADD" USING WS-HANDLE WS-PATTERN WS-DYEID
     END-PERFORM
     MOVE WS-HANDLE TO MN-WSLOT-VAR(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WSEL(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "sel " FUNCTION TRIM(WS-E1) " result " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sel -1 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance p70c loom close: the input banner and the carried result (a banner) go back to the player, nothing of the result slot" TO TL-CASE
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-BANNER AND PL-SLOT-COUNT(WS-ROW, WS-I) > 0
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E1
     MOVE MN-WINDOW(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "banners " FUNCTION TRIM(WS-E1) " window " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "banners 2 window 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     COMPUTE WS-X0 = WS-BX - 3
     COMPUTE WS-X1 = WS-BX + 3
     COMPUTE WS-Z0 = WS-BZ - 3
     COMPUTE WS-Z1 = WS-BZ + 3
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
                 COMPUTE WS-S = WS-BY + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-Z WS-AIR
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
 END PROGRAM ACC-P70C-LOOM.

 COPY CORETEST.
 COPY BETEST.
