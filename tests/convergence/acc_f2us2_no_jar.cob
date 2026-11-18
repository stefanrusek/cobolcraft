*> Convergence acceptance test of play without the operator's jar (spec 002 US2; SC-011, FR-003, FR-005, quickstart section 8), one test
*> for the whole story: with no generated directory (the client's generated directory names a folder that does not exist) and no
*> resource pack the client's start-up check reports the packs absent and the pack stack holds the built-in pack alone; a cobolcraft
*> world is created through the client host and played: a block is placed and one is broken with the controls (the place and break
*> buttons aimed at blocks), the Player moves, the crafting bench is crafted from the recipe book, placed and used and the goto_pad is
*> made at it, a block set with the standard command survives quit and reopen with the blocks the Player placed; every item icon of
*> the Player's inventory is drawn from the built-in pack (not the missing-texture sprite); and the create-world screen lets the
*> Player choose the standard type but refuses Create with the explanation, readable text and not a translation key, creating nothing.
*> Spawn (4.5, 54, 8.5) facing east; turf tops: (6, 53, 8), (5, 53, 7).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-NO-JAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us2-no-jar".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-FOLDER              PIC X(80) VALUE "NoJar".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-2             BINARY-LONG.
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
 01 WS-LIGHT               BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-GRID                PIC X(160).
 01 WS-PTR                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/generated-absent" TO CL-GENERATED-DIR
     MOVE 22 TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     MOVE CL-PACKS-STATUS TO WS-STATUS
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "T" TO TL-MODE
     MOVE "acceptance US2 SC-011 given no jar and no generated directory when the Player starts the "
         & "client and creates a cobolcraft world then the packs are absent and the world is played "
         & "as the cobolcraft type" TO TL-CASE
     MOVE "packs 1 joined 1 type 1" TO TL-EXPECTED
     MOVE WS-STATUS TO WS-E1
     MOVE WS-JOINED TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "packs " FUNCTION TRIM(WS-E1) " joined " FUNCTION TRIM(WS-E2) " type " CT-SET-TYPE
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every texture comes from the built-in pack: it is the whole pack stack, and no item icon of the inventory is the missing sprite.
     MOVE 0 TO WS-BAD
*>   (item 0 is the empty hand of the stand-in set and has no icon)
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 18
         IF IT-SPRITE(WS-I) <= 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US2 SC-011 given no jar and no resource pack when the world is played then the "
         & "pack stack is the built-in pack alone and every item icon is drawn from it, not the "
         & "missing-texture sprite" TO TL-CASE
     MOVE "packs 1 kind 0 missing icons 0" TO TL-EXPECTED
     MOVE PK-COUNT TO WS-E1
     MOVE PK-KIND(1) TO WS-E2
     MOVE WS-BAD TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "packs " FUNCTION TRIM(WS-E1) " kind " FUNCTION TRIM(WS-E2) " missing icons "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Place: greystone (slot 0) on the turf top at (6, 53, 8), then a cardstack (key 5: slot 4) on top of it.
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "F2NJ-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE "acceptance US2 SC-011 given no jar when the Player aims at the top face of turf and uses the "
         & "place control with greystone held then greystone appears above it, in the world and in "
         & "the client's replica" TO TL-CASE
     MOVE "core 2 client 2" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-5 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 54.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "F2NJ-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 55 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE "acceptance US2 SC-011 given no jar when the Player uses the place control on the greystone "
         & "with cardstack held then a cardstack (state 9) appears on top of it" TO TL-CASE
     MOVE "core 9 client 9" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Break: the cardstack by hand (1.0 s, standin 1.1) with greystone held; the greystone below it stays.
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 55.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "F2NJ-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 23 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 55 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE 54 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE "acceptance US2 SC-011 given no jar when the Player holds the break control on the cardstack "
         & "then it is gone in the world and in the client's replica and the greystone below stays"
         TO TL-CASE
     MOVE "cardstack core 0 client 0 greystone core 2 client 2" TO TL-EXPECTED
     MOVE WS-CORE TO WS-E3
     MOVE WS-STATE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "cardstack core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2)
         " greystone core " FUNCTION TRIM(WS-E3) " client " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Craft at the bench: two dump_shards from the give command; the bench recipe of the inventory screen's book (four ledger_tile) makes
*>   the crafting_bench, which goes to hotbar slot 8, is placed on the turf top at (5, 53, 7) and used; the goto_pad is made at it.
     MOVE "/give Alice cobolcraft:dump_shard 2" TO WS-TYPED
     MOVE 35 TO WS-TYPED-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TYPED WS-TYPED-LENGTH
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     PERFORM OPEN-BOOK
     MOVE "bench" TO WS-TYPED
     MOVE 5 TO WS-TYPED-LENGTH
     PERFORM SEARCH-FOR
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM GRID-TEXT
     MOVE "acceptance US2 SC-011 given no jar when the Player places the bench recipe from the book "
         & "then the grid holds four ledger_tile and the result is the crafting_bench (item 18)"
         TO TL-CASE
     MOVE "grid 1x9 1x9 1x9 1x9 result 1x18" TO TL-EXPECTED
     MOVE WS-GRID TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 105 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 8 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 0 TO WS-ITEM
     PERFORM FIND-SLOT
     PERFORM CLICK-LEFT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 7.5 TO WS-TZ
     CALL "F2NJ-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 7 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE "acceptance US2 SC-011 given the crafted bench in hotbar slot 8 when the Player uses the place "
         & "control on the turf top then the crafting_bench block (state 18) stands there in the world "
         & "and in the client's replica" TO TL-CASE
     MOVE "core 18 client 18" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 7.5 TO WS-TZ
     CALL "F2NJ-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-BENCH AND BM-ID > 0
         MOVE "bench screen" TO TL-OBSERVED
     ELSE
         MOVE SM-SCREEN TO WS-E1
         STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "acceptance US2 SC-011 given the placed bench when the Player uses it then the crafting screen "
         & "opens with a container id" TO TL-CASE
     MOVE "bench screen" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM OPEN-BOOK
     MOVE "goto" TO WS-TYPED
     MOVE 4 TO WS-TYPED-LENGTH
     PERFORM SEARCH-FOR
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 6 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 105 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US2 SC-011 given the bench screen when the Player places the goto_pad recipe and "
         & "takes the result then the cursor holds a goto_pad (item 16)" TO TL-CASE
     MOVE "cursor 1x16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   Move: W held for two seconds takes the Player at least a block.
     MOVE PL-X TO WS-X0
     MOVE PL-Z TO WS-Z0
     MOVE CC-KEY-W TO WS-KEY
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-DOWN
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-X TO WS-X1
     MOVE PL-Z TO WS-Z1
     COMPUTE WS-MOVED = FUNCTION SQRT((WS-X1 - WS-X0) ** 2 + (WS-Z1 - WS-Z0) ** 2)
     MOVE "acceptance US2 SC-011 given no jar when the Player holds W then the Player moves" TO TL-CASE
     MOVE "moved 1" TO TL-EXPECTED
     MOVE 0 TO WS-E1
     IF WS-MOVED >= 1
         MOVE 1 TO WS-E1
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "moved " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block set with the standard command, then the world is quit and opened again.
     MOVE "/setblock 4 60 4 cobolcraft:greystone" TO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "SP-QUIT" USING CLIENT-STATE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 4 TO WS-PX
     MOVE 60 TO WS-PY
     MOVE 4 TO WS-PZ
     CALL "WORLD-CELL" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-BLOCK-2 WS-SKY WS-BLOCK
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE "acceptance US2 SC-011 given the world quit and opened again when the Player looks at the "
         & "blocks they set and placed then they are there (not air) and the Player is back in play"
         TO TL-CASE
     MOVE "joined 1 set block 1 placed greystone 2" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-BLOCK-2 > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CORE TO WS-E3
     STRING "joined " FUNCTION TRIM(WS-E1) " set block " FUNCTION TRIM(WS-E2) " placed greystone "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The create-world screen: standard is selectable (one click from the cobolcraft default), Create is refused with the explanation in
*>   readable text and nothing is created.
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE SCR-CREATE-WORLD TO WS-ACTION
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ACTION
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE ACT-WORLD-TYPE TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: Standard"
     MOVE WS-HITS TO WS-E1
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-E2
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "cobolcraft."
     MOVE WS-HITS TO WS-E3
     CALL "SYSTEM" USING "test -d build/conv-f2us2-no-jar/Alice/saves/New_World"
     MOVE 0 TO WS-BAD
     IF RETURN-CODE NOT = 0
         MOVE 1 TO WS-BAD
     END-IF
     MOVE "acceptance US2 SC-011 FR-003 given no jar when the Player chooses the standard type and "
         & "clicks Create then the explanation is shown in readable text (no translation key), standard "
         & "stays chosen and no world folder is created" TO TL-CASE
     MOVE "standard 1 explanation 1 keys 0 no folder 1 screen 14" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E5
     MOVE WS-BAD TO WS-E4
     STRING "standard " FUNCTION TRIM(WS-E1) " explanation " FUNCTION TRIM(WS-E2) " keys "
         FUNCTION TRIM(WS-E3) " no folder " FUNCTION TRIM(WS-E4) " screen " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

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

 BOTH-OBSERVED.
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED.

*>   The widget slot WS-ARG clicked with the left button, then two frames.
 CLICK-LEFT.
     MOVE CC-BUTTON-LEFT TO WS-KEY
     CALL "F2NJ-CLICK" USING CONVH WS-ALICE WS-KEY WS-ARG WS-FOUND
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
 END PROGRAM ACC-F2US2-NO-JAR.

*> Test helpers (test infrastructure).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2NJ-AIM-AT.
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
     CALL "F2NJ-ATAN2-DEG" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "F2NJ-ATAN2-DEG" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM F2NJ-AIM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2NJ-ATAN2-DEG.
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
 END PROGRAM F2NJ-ATAN2-DEG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2NJ-CLICK.
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
 END PROGRAM F2NJ-CLICK.

