*> Acceptance test, lane bugplacehead (operator report: "clicking a wall in a confined space so that the torch would be placed in the same space as my head doesn't work";
*> docs/protocol 29 section 9.6 canPlace / Level.isUnobstructed: a block is placed when its COLLISION shape does not intersect a blocking entity, so a torch, sign,
*> ladder, button, lever, flower or rail goes into a cell the player's body is in, and a full block, stairs, fence, slab or carpet whose collision shape meets the box does
*> not; the player's own box counts, a spectator's and an item entity's does not): a superflat world (the standard content set) opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). The player stands in a corridor one cell wide: stone on four sides and above, a
*> grass floor, feet in the cell at y = floor + 1 and head in the cell above (the box is 0.6 wide and 1.8 high). Items are used on the wall (or the floor) through the
*> real Use Item On packet path and the block that results in the target cell is read back. The same items go in with a cow standing in the cell instead of the player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PLACE-HEAD-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
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
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(40).
 01 WS-WANT-KEY            PIC X(40).
 01 WS-GOT-KEY             PIC X(40).
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-CLICK-Y             BINARY-LONG.
 01 WS-CELL-TXT            PIC X.
 01 WS-ITEM-TXT            PIC X(40).
 01 WS-WANT-TXT            PIC X(40).
 01 WS-COW-TXT             PIC X(40).
 01 WS-CLICK-Z             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-WHERE               PIC X(16).
 01 WS-WHO                 PIC X(8).
 01 WS-COW                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-LINE               PIC X(60).
 01 WS-CASES.
*>   One row per case: the cell (F the feet cell and H the head cell, both by a click on the north wall; G the feet cell by a click on the floor; C the head cell by a click under the roof), the item, and the block that
*>   must result in the cell (- when the placement must be refused).
    05 FILLER PIC X(60) VALUE "F|torch|wall_torch".
    05 FILLER PIC X(60) VALUE "H|torch|wall_torch".
    05 FILLER PIC X(60) VALUE "F|redstone_torch|redstone_wall_torch".
    05 FILLER PIC X(60) VALUE "H|redstone_torch|redstone_wall_torch".
    05 FILLER PIC X(60) VALUE "F|oak_sign|oak_wall_sign".
    05 FILLER PIC X(60) VALUE "H|oak_sign|oak_wall_sign".
    05 FILLER PIC X(60) VALUE "F|ladder|ladder|-".
    05 FILLER PIC X(60) VALUE "H|ladder|ladder|-".
    05 FILLER PIC X(60) VALUE "F|stone_button|stone_button".
    05 FILLER PIC X(60) VALUE "H|stone_button|stone_button".
    05 FILLER PIC X(60) VALUE "F|lever|lever".
    05 FILLER PIC X(60) VALUE "H|lever|lever".
    05 FILLER PIC X(60) VALUE "F|stone|-".
    05 FILLER PIC X(60) VALUE "H|stone|-".
    05 FILLER PIC X(60) VALUE "F|oak_stairs|-".
    05 FILLER PIC X(60) VALUE "H|oak_stairs|-".
    05 FILLER PIC X(60) VALUE "F|oak_fence|-".
    05 FILLER PIC X(60) VALUE "H|oak_fence|-".
    05 FILLER PIC X(60) VALUE "F|oak_slab|-".
    05 FILLER PIC X(60) VALUE "F|glass|-".
    05 FILLER PIC X(60) VALUE "G|torch|torch".
    05 FILLER PIC X(60) VALUE "G|poppy|poppy".
    05 FILLER PIC X(60) VALUE "G|rail|rail".
    05 FILLER PIC X(60) VALUE "G|white_carpet|-".
    05 FILLER PIC X(60) VALUE "G|oak_slab|-".
    05 FILLER PIC X(60) VALUE "G|stone|-".
    05 FILLER PIC X(60) VALUE "G|oak_sign|oak_sign".
    05 FILLER PIC X(60) VALUE "G|white_banner|white_banner".
    05 FILLER PIC X(60) VALUE "F|white_banner|white_wall_banner".
    05 FILLER PIC X(60) VALUE "H|white_banner|white_wall_banner".
    05 FILLER PIC X(60) VALUE "G|stone_pressure_plate|stone_pressure_plate".
    05 FILLER PIC X(60) VALUE "G|oak_pressure_plate|oak_pressure_plate".
    05 FILLER PIC X(60) VALUE "G|stone_button|stone_button".
    05 FILLER PIC X(60) VALUE "G|lever|lever".
    05 FILLER PIC X(60) VALUE "G|oak_sapling|oak_sapling".
    05 FILLER PIC X(60) VALUE "G|redstone|redstone_wire".
    05 FILLER PIC X(60) VALUE "C|oak_hanging_sign|oak_hanging_sign".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-ROW         PIC X(60) OCCURS 37 TIMES.
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
         MOVE "acceptance place head standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "PlaceHead" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-BLOCK-STATE
     MOVE WS-STATE TO WS-STONE
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-BLOCK-STATE
     MOVE WS-STATE TO WS-GRASS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     COMPUTE WS-CX = WS-BX + 6
     COMPUTE WS-CZ = WS-BZ + 6
*>   A grass floor, air above it, and the corridor cell (CX, CZ) walled with stone on four sides and above (floor + 1 to floor + 3).
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-GRASS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-Y = WS-FLOOR + WS-I
         COMPUTE WS-X = WS-CX - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-CZ WS-STONE
         COMPUTE WS-X = WS-CX + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-CZ WS-STONE
         COMPUTE WS-Z = WS-CZ - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
         COMPUTE WS-Z = WS-CZ + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
     END-PERFORM
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-STONE
     COMPUTE WS-Y = WS-FLOOR + 3

*>   The player in the corridor, feet at the floor of the cell.
     MOVE "Alice" TO WS-WHO
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         MOVE WS-CASE-ROW(WS-I) TO WS-LINE
         PERFORM RUN-CASE
     END-PERFORM

*>   The player's feet half a block up (standing on something that is not there): a bottom slab or a carpet in the cell stays below the box, so it is placed; a full block still meets it.
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1.5
     MOVE "Alice up" TO WS-WHO
     MOVE "G|oak_slab|oak_slab" TO WS-LINE
     PERFORM RUN-CASE
     MOVE "G|stone|-" TO WS-LINE
     PERFORM RUN-CASE
     MOVE "G|white_carpet|white_carpet" TO WS-LINE
     PERFORM RUN-CASE

*>   The body test itself: a spectator's box does not obstruct a full block, a survival player's does.
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE WS-CELL-Y = WS-FLOOR + 1
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-CX WS-CELL-Y WS-CZ WS-STONE WS-LEFT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance place head standard: a spectator's box does not obstruct a full block" TO WS-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-CX WS-CELL-Y WS-CZ WS-STONE WS-LEFT
     MOVE "acceptance place head standard: a survival player's box obstructs a full block" TO WS-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-CX WS-CELL-Y WS-CZ WS-AIR WS-LEFT
     MOVE "acceptance place head standard: the void has no collision shape and obstructs nothing" TO WS-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N

*>   A cow in the corridor instead of the player (the player stands outside the east wall): the cow's box is a living entity's and obstructs what has a collision shape only.
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 2.5
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ID WS-FX WS-FY WS-FZ WS-YAW WS-COW
     MOVE "cow" TO WS-WHO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         MOVE WS-CASE-ROW(WS-I) TO WS-LINE
         PERFORM RUN-CASE
     END-PERFORM
     STOP RUN.

*> One case in WS-LINE (cell|item|wanted block|wanted block with the cow): the item used on the north wall (F, H) or on the floor (G), the block read back in the target cell against the wanted key.
 RUN-CASE.
     MOVE SPACES TO WS-CELL-TXT WS-ITEM-TXT WS-WANT-TXT WS-COW-TXT
     UNSTRING WS-LINE DELIMITED BY "|" INTO WS-CELL-TXT WS-ITEM-TXT WS-WANT-TXT WS-COW-TXT
*>   A fourth field is the result with the cow in the cell: a ladder's plate (3/16 thick, on the wall) misses the player's 0.6 wide box but meets the cow's 0.9 wide one.
     IF WS-WHO = "cow" AND WS-COW-TXT NOT = SPACES
         MOVE WS-COW-TXT TO WS-WANT-TXT
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-TXT) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     EVALUATE WS-CELL-TXT
         WHEN "G"
             COMPUTE WS-CELL-Y = WS-FLOOR + 1
             MOVE WS-FLOOR TO WS-CLICK-Y
             MOVE WS-CZ TO WS-CLICK-Z
             MOVE 1 TO WS-FACE
             MOVE "feet (floor)" TO WS-WHERE
         WHEN "F"
             COMPUTE WS-CELL-Y = WS-FLOOR + 1
             MOVE WS-CELL-Y TO WS-CLICK-Y
             COMPUTE WS-CLICK-Z = WS-CZ - 1
             MOVE 3 TO WS-FACE
             MOVE "feet (wall)" TO WS-WHERE
         WHEN "C"
*>           The underside of the roof: the head cell, a hanging sign under the stone above it.
             COMPUTE WS-CELL-Y = WS-FLOOR + 2
             COMPUTE WS-CLICK-Y = WS-FLOOR + 3
             MOVE WS-CZ TO WS-CLICK-Z
             MOVE 0 TO WS-FACE
             MOVE "head (ceiling)" TO WS-WHERE
         WHEN OTHER
             COMPUTE WS-CELL-Y = WS-FLOOR + 2
             MOVE WS-CELL-Y TO WS-CLICK-Y
             COMPUTE WS-CLICK-Z = WS-CZ - 1
             MOVE 3 TO WS-FACE
             MOVE "head (wall)" TO WS-WHERE
     END-EVALUATE
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CLICK-Y WS-CLICK-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CELL-Y WS-CZ WS-STATE
     MOVE "-" TO WS-GOT-KEY
     IF WS-STATE > 0
         COMPUTE WS-E = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-E)(1:40) TO WS-GOT-KEY
     END-IF
     MOVE SPACES TO WS-CASE
     STRING "acceptance place head standard: " FUNCTION TRIM(WS-WHO) " " FUNCTION TRIM(WS-ITEM-TXT) " into the " FUNCTION TRIM(WS-WHERE)
         " cell gives " FUNCTION TRIM(WS-WANT-TXT) DELIMITED BY SIZE INTO WS-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WANT-TXT TO TL-EXPECTED
     MOVE WS-GOT-KEY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A refused placement keeps the item, a placed block uses one up (survival).
     MOVE 5 TO TL-EXPECTED-N
     IF WS-STATE > 0
         MOVE 4 TO TL-EXPECTED-N
     END-IF
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance place head standard: item count after " FUNCTION TRIM(WS-WHO) " " FUNCTION TRIM(WS-ITEM-TXT) " "
         FUNCTION TRIM(WS-WHERE) DELIMITED BY SIZE INTO TL-CASE
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CELL-Y WS-CZ WS-AIR.

*> WS-STATE: the default state of the block WS-KEY (no namespace in the generated set), 0 when the table has none.
 FIND-BLOCK-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-STATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-PLACE-HEAD-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
