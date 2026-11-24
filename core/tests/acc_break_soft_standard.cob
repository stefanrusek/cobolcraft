*> Acceptance test, lane wallitems (operator report "I couldn't break torches"; CC-0009 FR-005; docs/protocol/29 section 10.1 and 13 section 2.1): a
*> superflat world of the generated standard content set (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). Zero-hardness blocks
*> that are not full cubes (torches, wall torches, redstone torches, flowers, grass, ferns, saplings, mushrooms, sugar cane, wheat, a tall grass, a vine, a
*> tripwire) are hit through the real Player Action path (Start Destroy Block, then the Stop Destroy Block the client sends after its zero break time) by a
*> survival and by a creative player with an empty hand: the block is gone after the Start, a survival player leaves an item on the ground and a creative
*> player does not, the Stop that follows changes nothing, and the player's break state is clear.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BREAK-SOFT-STANDARD.
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
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
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
 01 WS-UPPER               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-MODE-TEXT         PIC X(8).
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-LIST.
    05 FILLER              PIC X(48) VALUE "torch".
    05 FILLER              PIC X(48) VALUE "soul_torch".
    05 FILLER              PIC X(48) VALUE "redstone_torch".
    05 FILLER              PIC X(48) VALUE "copper_torch".
    05 FILLER              PIC X(48) VALUE "dandelion".
    05 FILLER              PIC X(48) VALUE "poppy".
    05 FILLER              PIC X(48) VALUE "short_grass".
    05 FILLER              PIC X(48) VALUE "fern".
    05 FILLER              PIC X(48) VALUE "dead_bush".
    05 FILLER              PIC X(48) VALUE "oak_sapling".
    05 FILLER              PIC X(48) VALUE "red_mushroom".
    05 FILLER              PIC X(48) VALUE "sugar_cane".
    05 FILLER              PIC X(48) VALUE "wheat".
    05 FILLER              PIC X(48) VALUE "tall_grass".
    05 FILLER              PIC X(48) VALUE "tripwire".
    05 FILLER              PIC X(48) VALUE "redstone_wire".
 01 WS-LIST-TABLE REDEFINES WS-LIST.
    05 WS-LIST-KEY         PIC X(48) OCCURS 16 TIMES.
 01 WS-WALLS.
    05 FILLER              PIC X(48) VALUE "wall_torch".
    05 FILLER              PIC X(48) VALUE "soul_wall_torch".
    05 FILLER              PIC X(48) VALUE "redstone_wall_torch".
    05 FILLER              PIC X(48) VALUE "copper_wall_torch".
 01 WS-WALL-TABLE REDEFINES WS-WALLS.
    05 WS-WALL-KEY         PIC X(48) OCCURS 4 TIMES.
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
         MOVE "acceptance break soft standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "BreakSoft" TO CS-NEW-WORLD-NAME
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
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     COMPUTE WS-Y = WS-FLOOR + 1

*>   Blocks that stand on the floor: mode 0 survival, 1 creative.
     PERFORM VARYING WS-MODE FROM 0 BY 1 UNTIL WS-MODE > 1
         MOVE WS-MODE TO PL-MODE(WS-PLAYER)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE WS-LIST-KEY(WS-I) TO WS-KEY
             PERFORM FIND-STATE
             COMPUTE WS-X = WS-BX + 1 + FUNCTION MOD(WS-I - 1, 8)
             COMPUTE WS-Z = WS-BZ + 7 + (WS-I - 1) / 8
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-KEY = "tall_grass"
                 MOVE "tall_grass" TO WS-KEY112
                 MOVE "half=upper" TO WS-PAIRS
                 CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-UPPER
                 COMPUTE WS-E = WS-Y + 1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-UPPER
             END-IF
             PERFORM HIT-CELL
         END-PERFORM
*>       Wall torches on the side of a stone block (the block south of the cell, facing north).
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-WALL-KEY(WS-I) TO WS-KEY
             MOVE WS-KEY TO WS-KEY112
             MOVE "facing=north" TO WS-PAIRS
             IF WS-I = 3
                 MOVE "facing=north,lit=true" TO WS-PAIRS
             END-IF
             CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
             COMPUTE WS-X = WS-BX + 1 + WS-I
             COMPUTE WS-Z = WS-BZ + 4
             COMPUTE WS-E = WS-Z + 1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-E WS-STONE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             PERFORM HIT-CELL
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-E WS-AIR
         END-PERFORM
     END-PERFORM
     STOP RUN.

*> Hits the block at WS-X, WS-Y, WS-Z (WS-KEY, mode WS-MODE) with Start Destroy Block, then Stop Destroy Block: the cell is void, a survival break leaves
*> an item on the ground and a creative one none, the player is not left breaking.
 HIT-CELL.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         MOVE 0 TO EN-USED(WS-K)
     END-PERFORM
     MOVE 1 TO WS-FACE
     MOVE "survival" TO WS-MODE-TEXT
     IF WS-MODE = 1
         MOVE "creative" TO WS-MODE-TEXT
     END-IF
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE SPACES TO WS-CASE
     IF WS-MODE = 0
         STRING "acceptance break soft standard: a survival player's Start Destroy Block removes " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     ELSE
         STRING "acceptance break soft standard: a creative player's Start Destroy Block removes " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     END-IF
     PERFORM CHECK-N
     MOVE 3 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-OBSERVE
     MOVE SPACES TO WS-CASE
     STRING "acceptance break soft standard: the Stop Destroy Block after the break leaves " FUNCTION TRIM(WS-KEY) " removed (" FUNCTION TRIM(WS-MODE-TEXT) ")"
         DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-N
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0 AND EN-ITEM-COUNT(WS-K) > 0
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM
     IF WS-MODE = 0
         MOVE 1 TO WS-EXPECT
     ELSE
         MOVE 0 TO WS-EXPECT
     END-IF
*>   Short grass and tall grass drop by chance (their loot tables are random), so the count is not asserted for them.
     MOVE WS-ITEMS TO WS-OBSERVE
     IF WS-MODE = 0 AND (WS-KEY = "short_grass" OR WS-KEY = "tall_grass")
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE SPACES TO WS-CASE
     STRING "acceptance break soft standard: items on the ground after breaking " FUNCTION TRIM(WS-KEY) " (" FUNCTION TRIM(WS-MODE-TEXT) ")" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-N
     MOVE 0 TO WS-EXPECT
     MOVE PL-BREAKING(WS-PLAYER) TO WS-OBSERVE
     MOVE SPACES TO WS-CASE
     STRING "acceptance break soft standard: the player is not left breaking after " FUNCTION TRIM(WS-KEY) " (" FUNCTION TRIM(WS-MODE-TEXT) ")" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-N.

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
 END PROGRAM ACC-BREAK-SOFT-STANDARD.
 COPY CORETEST.
