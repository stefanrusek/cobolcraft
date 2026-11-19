*> Acceptance test, lane bugcreative (operator report of try15 "creative mode can't break bedrock"; docs/protocol/13 sections 2.1 and 2.5, 29 section
*> 10.4, 24 and 31-6 section 11.1; docs/design/standin-content.md section 1.1). A superflat world of the generated standard content set (CC_GENERATED_DIR,
*> default /tmp/cc-test/generated; skipped as a pass without it). The server breaks at once on Start Destroy Block when the player has instabuild, whatever
*> the block's hardness (bedrock, barrier, end portal frame, reinforced deepslate, light, structure block, jigsaw; the command blocks need creative AND the
*> game master permission), with no item on the ground, a Level Event 2001 for everybody but the breaker, both halves of a door, and a waterlogged block
*> leaving its water; a sword, a trident or a mace in the main hand cannot break anything in creative; survival and adventure cannot break bedrock.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-BREAK-UNBREAKABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BOBROW              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LIST.
    05 FILLER              PIC X(48) VALUE "bedrock".
    05 FILLER              PIC X(48) VALUE "barrier".
    05 FILLER              PIC X(48) VALUE "end_portal_frame".
    05 FILLER              PIC X(48) VALUE "reinforced_deepslate".
    05 FILLER              PIC X(48) VALUE "light".
    05 FILLER              PIC X(48) VALUE "structure_block".
    05 FILLER              PIC X(48) VALUE "jigsaw".
    05 FILLER              PIC X(48) VALUE "command_block".
    05 FILLER              PIC X(48) VALUE "repeating_command_block".
    05 FILLER              PIC X(48) VALUE "chain_command_block".
 01 WS-LIST-TABLE REDEFINES WS-LIST.
    05 WS-LIST-KEY         PIC X(48) OCCURS 10 TIMES.
 01 WS-GAME-MASTER-FROM    BINARY-LONG VALUE 6.
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
         MOVE "acceptance break unbreakable no generated packs here, skipped" TO TL-CASE
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
     MOVE "BreakUnbreakable" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-WATER
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE CN-PLAYER(WS-BOB) TO WS-BOBROW
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     COMPUTE PL-X(WS-BOBROW) = WS-BX + 8.5
     COMPUTE PL-Y(WS-BOBROW) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-BOBROW) = WS-BZ + 11.5
     MOVE 0 TO PL-MODE(WS-BOBROW)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM EMPTY-HAND
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     CALL "TEST-DRAIN-HUNGER" USING WS-BOB WS-TEXT-AREA
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-X = WS-BX + 3
     COMPUTE WS-Z = WS-BZ + 7

*>   Creative with the game master permission: every block of the list breaks on Start Destroy Block, leaves no item and sends the other player the
*>   Level Event 2001 (the breaker is excluded); the Stop that follows changes nothing.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO PL-OPERATOR(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-LIST-KEY(WS-I) TO WS-KEY
         PERFORM PUT-BLOCK
         PERFORM HIT-CELL
         MOVE 0 TO WS-EXPECT
         MOVE WS-STATE TO WS-OBSERVE
         MOVE SPACES TO WS-CASE
         STRING "acceptance break unbreakable: a creative player's Start Destroy Block removes " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-N
         MOVE 0 TO WS-EXPECT
         MOVE WS-ITEMS TO WS-OBSERVE
         MOVE SPACES TO WS-CASE
         STRING "acceptance break unbreakable: no item on the ground after the creative break of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-N
     END-PERFORM
     MOVE "bedrock" TO WS-KEY
     PERFORM PUT-BLOCK
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM HIT-CELL
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     PERFORM COUNT-EVENT
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     MOVE "acceptance break unbreakable: the other player gets the Level Event 2001 of the creative break of bedrock" TO WS-CASE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM COUNT-EVENT
     MOVE 0 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     MOVE "acceptance break unbreakable: the breaker does not get the Level Event 2001 of the creative break" TO WS-CASE
     PERFORM CHECK-N

*>   A creative player without the game master permission cannot break a command block, a structure block or a jigsaw block; the block stays.
     MOVE 0 TO PL-OPERATOR(WS-PLAYER)
     PERFORM VARYING WS-I FROM WS-GAME-MASTER-FROM BY 1 UNTIL WS-I > 10
         MOVE WS-LIST-KEY(WS-I) TO WS-KEY
         PERFORM PUT-BLOCK
         PERFORM HIT-CELL
         MOVE 1 TO WS-EXPECT
         COMPUTE WS-OBSERVE = FUNCTION MIN(WS-STATE, 1)
         MOVE SPACES TO WS-CASE
         STRING "acceptance break unbreakable: a creative player who is no game master cannot break " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-N
     END-PERFORM
     MOVE "bedrock" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM HIT-CELL
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance break unbreakable: bedrock needs no permission, a creative player without one breaks it" TO WS-CASE
     PERFORM CHECK-N

*>   A sword, a trident or a mace cannot break any block in creative; a pickaxe can.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         EVALUATE WS-K
             WHEN 1 MOVE "diamond_sword" TO WS-KEY
             WHEN 2 MOVE "trident" TO WS-KEY
             WHEN 3 MOVE "mace" TO WS-KEY
             WHEN OTHER MOVE "wooden_sword" TO WS-KEY
         END-EVALUATE
         PERFORM HOLD-ITEM
         MOVE "bedrock" TO WS-KEY
         PERFORM PUT-BLOCK
         PERFORM HIT-CELL
         MOVE 1 TO WS-EXPECT
         COMPUTE WS-OBSERVE = FUNCTION MIN(WS-STATE, 1)
         MOVE "acceptance break unbreakable: a creative player holding a sword, a trident or a mace cannot break bedrock" TO WS-CASE
         PERFORM CHECK-N
         MOVE "stone" TO WS-KEY
         PERFORM PUT-BLOCK
         PERFORM HIT-CELL
         MOVE 1 TO WS-EXPECT
         COMPUTE WS-OBSERVE = FUNCTION MIN(WS-STATE, 1)
         MOVE "acceptance break unbreakable: a creative player holding a sword, a trident or a mace cannot break stone either" TO WS-CASE
         PERFORM CHECK-N
     END-PERFORM
     MOVE "diamond_pickaxe" TO WS-KEY
     PERFORM HOLD-ITEM
     MOVE "bedrock" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM HIT-CELL
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance break unbreakable: a creative player holding a pickaxe breaks bedrock" TO WS-CASE
     PERFORM CHECK-N
     PERFORM EMPTY-HAND

*>   Survival and adventure cannot break bedrock: not on Start, not on the Stop that follows.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         IF WS-K NOT = 1
             MOVE WS-K TO PL-MODE(WS-PLAYER)
             MOVE "bedrock" TO WS-KEY
             PERFORM PUT-BLOCK
             PERFORM HIT-CELL
             MOVE 3 TO WS-ACTION
             ADD 1 TO WS-SEQ
             CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             MOVE 1 TO WS-EXPECT
             COMPUTE WS-OBSERVE = FUNCTION MIN(WS-STATE, 1)
             MOVE "acceptance break unbreakable: a survival or an adventure player cannot break bedrock" TO WS-CASE
             PERFORM CHECK-N
         END-IF
     END-PERFORM

*>   Both halves of a door go in creative, and a waterlogged block leaves its water.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "oak_door" TO WS-KEY112
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     COMPUTE WS-E = WS-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-STATE
     PERFORM HIT-CELL
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-STATE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance break unbreakable: the creative break of the lower half of a door takes the upper half too" TO WS-CASE
     PERFORM CHECK-N
     MOVE "oak_slab" TO WS-KEY112
     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "oak_slab" TO WS-KEY
     PERFORM HIT-CELL
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance break unbreakable: a waterlogged slab broken in creative leaves its water source" TO WS-CASE
     PERFORM CHECK-N

*>   The survival break sends the same Level Event 2001 to the other player (a dandelion has no break time: Start breaks it).
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "dandelion" TO WS-KEY
     PERFORM PUT-BLOCK
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     PERFORM HIT-CELL
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     PERFORM COUNT-EVENT
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     MOVE "acceptance break unbreakable: the other player gets the Level Event 2001 of a survival break" TO WS-CASE
     PERFORM CHECK-N
     MOVE "oak_slab" TO WS-KEY112
     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     STOP RUN.

*> Puts the block WS-KEY (default state) at WS-X, WS-Y, WS-Z.
 PUT-BLOCK.
     PERFORM FIND-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE.

*> Start Destroy Block at the cell by Alice, then the state of the cell and the items on the ground (WS-ITEMS).
 HIT-CELL.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         MOVE 0 TO EN-USED(WS-J)
     END-PERFORM
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0 AND EN-ITEM-COUNT(WS-J) > 0
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.

*> The number of packets of id 47 (Level Event) in the last drain (WS-IDS) into WS-HITS.
 COUNT-EVENT.
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "47".

 EMPTY-HAND.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1).

*> The item WS-KEY in the first hotbar slot, held.
 HOLD-ITEM.
     MOVE WS-KEY TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

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
 END PROGRAM ACC-US4-BREAK-UNBREAKABLE.
 COPY CORETEST.
