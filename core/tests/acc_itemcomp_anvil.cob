*> Acceptance test, the anvil as a live menu through the real play path (docs/protocol/40-menus-3 section 3; lane itemcomp2, T10102): Use Item On opens the anvil menu (family 24, 3 own
*> slots, result slot 2), shift clicks send a damaged iron pickaxe and iron ingots to the inputs, the result and its cost (data slot 0) follow, the result cannot be taken without the levels,
*> with them the click pays the levels, uses two ingots, empties the left slot and gives the repaired pickaxe; a Rename Item names a sword for 1 level and keeps it as only renaming.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEMCOMP-ANVIL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY PLAYPKT.
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
     MOVE "anvil" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-TABLE
     MOVE "iron_pickaxe" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PICK
     MOVE "iron_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
     MOVE "diamond_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SWORD
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-TABLE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK

     MOVE "acceptance itemcomp anvil open: Use Item On the anvil opens a station menu of family 24 with 3 own slots, the result is slot 2" TO TL-CASE
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-WRES(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "family " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "family 24 size 3 result 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp anvil repair: shift clicks put a pickaxe of damage 100 and three iron ingots in the inputs, the result costs 2 levels; without levels it stays" TO TL-CASE
     MOVE 100 TO WS-DMG
     MOVE 0 TO WS-VAR
     CALL "SP-SET-DAMAGE" USING WS-VAR WS-DMG
     MOVE WS-PICK TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-VAR TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE WS-INGOT TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     PERFORM VARYING WS-S FROM 30 BY 1 UNTIL WS-S > 31
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     END-PERFORM
     MOVE 0 TO WS-TYPE
     MOVE 2 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "cost " FUNCTION TRIM(WS-E1) " result " FUNCTION TRIM(WS-E2) " cursor " FUNCTION TRIM(WS-E3) " ingots " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cost 2 result 1 cursor 0 ingots 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp anvil take: with 5 levels the click gives the repaired pickaxe, 2 levels are paid, two of the ingots are used, the left slot is empty" TO TL-CASE
     MOVE 5 TO PL-XP-LEVEL(WS-ROW)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE PL-XP-LEVEL(WS-ROW) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E4
     MOVE PL-CARRIED-VAR(WS-ROW) TO WS-VAR
     CALL "SP-GET-DAMAGE" USING WS-PICK WS-VAR WS-DMG
     MOVE WS-DMG TO WS-E5
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " levels " FUNCTION TRIM(WS-E2) " ingots " FUNCTION TRIM(WS-E3) " left " FUNCTION TRIM(WS-E4)
         " damage " FUNCTION TRIM(WS-E5) " cost " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 1 levels 3 ingots 1 left 0 damage 0 cost 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp anvil rename: a Rename Item with Blade names a sword for 1 level, it is only renaming and the result carries the name" TO TL-CASE
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-VAR(WS-ROW)
     MOVE WS-SWORD TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO MN-WSLOT-VAR(WS-ROW, 1) MN-WSLOT-COUNT(WS-ROW, 2) MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE "Blade" TO PSB-MESSAGE
     MOVE 5 TO PSB-MESSAGE-LENGTH
     CALL "ANVIL-RENAME" USING WS-CONN PLAY-SERVERBOUND
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E1
     MOVE MN-WKEEP(WS-ROW) TO WS-E2
     MOVE MN-RESULT-VAR(WS-ROW) TO WS-VAR
     CALL "SP-GET-NAME" USING WS-VAR WS-TEXT WS-N
     MOVE WS-N TO WS-E3
     MOVE WS-TEXT(1:5) TO WS-TITLE
     MOVE SPACES TO WS-TEXT
     STRING "cost " FUNCTION TRIM(WS-E1) " only " FUNCTION TRIM(WS-E2) " name " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-TITLE)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cost 1 only 1 name 5 Blade" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp anvil rename refusals: a name of 51 characters or the same name again changes nothing; section signs and control characters are dropped" TO TL-CASE
     MOVE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" TO PSB-MESSAGE
     MOVE 51 TO PSB-MESSAGE-LENGTH
     CALL "ANVIL-RENAME" USING WS-CONN PLAY-SERVERBOUND
     MOVE MN-WNAME-LEN(WS-ROW) TO WS-E1
     MOVE "Blade" TO PSB-MESSAGE
     MOVE 5 TO PSB-MESSAGE-LENGTH
     CALL "ANVIL-RENAME" USING WS-CONN PLAY-SERVERBOUND
     MOVE MN-WNAME-LEN(WS-ROW) TO WS-E2
     MOVE X"42C2A74C0A61" TO PSB-MESSAGE(1:6)
     MOVE 6 TO PSB-MESSAGE-LENGTH
     CALL "ANVIL-RENAME" USING WS-CONN PLAY-SERVERBOUND
     MOVE MN-WNAME-LEN(WS-ROW) TO WS-E3
     MOVE MN-WNAME(WS-ROW)(1:3) TO WS-TITLE
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-TITLE) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "5 5 3 BLa" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

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
 END PROGRAM ACC-ITEMCOMP-ANVIL.

 COPY CORETEST.
 COPY BETEST.
