*> Acceptance test, lane bugfountain (operator report try15: "water buckets don't place either, they used to" and "I can't pick up the top block with a bucket"):
*> buckets through the real packet path in a standard world (generated vanilla data pack, CC_GENERATED_DIR; skipped as a pass without it) the way the
*> client sends them (29a section 7.1 to 7.3; client/src/controls.cob): Use Item On the block aimed at, then Use Item with the same bucket. A stone
*> wall stands on a platform high above the terrain; the player looks along +z. An empty bucket picks up a water or lava source ahead; a water or lava bucket
*> places its source in the cell before the wall.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFOUNTAIN-BUCKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
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
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-WATER-BUCKET        BINARY-LONG.
 01 WS-LAVA-BUCKET         BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 2.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-WANT-STATE          BINARY-LONG.
 01 WS-WANT-ITEM           BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-WITH-ON             BINARY-LONG VALUE 0.
 01 WS-TAG                 PIC X(40).
 01 WS-ROUND               BINARY-LONG.
 01 WS-FENCE-DRY           BINARY-LONG.
 01 WS-FENCE-WET           BINARY-LONG.
 01 WS-KELP                BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "waterlogged".
 01 WS-PTEXT               PIC X(32).
 01 WS-PMODE               BINARY-LONG VALUE 2.
 01 WS-PITCH               FLOAT-SHORT VALUE 90.
 01 WS-GY                  BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-MODE-TEXT           PIC 9.
 01 WS-TEXT-AREA           PIC X(4096).
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
         MOVE "acceptance bugfountain bucket no generated packs here, skipped" TO TL-CASE
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
     MOVE "Bugfountain" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "lava" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-LAVA
     MOVE "bucket" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM-ID TO WS-BUCKET
     MOVE "water_bucket" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM-ID TO WS-WATER-BUCKET
     MOVE "lava_bucket" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM-ID TO WS-LAVA-BUCKET
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 4.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
*>   The wall: (bx + 6, floor + 2, bz + 8); the ray runs along z through the cells bz + 4 to bz + 7 at y floor + 2.
     COMPUTE WS-WX = WS-BX + 6
     COMPUTE WS-WY = WS-FLOOR + 2
     COMPUTE WS-WZ = WS-BZ + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
     MOVE WS-WX TO WS-CX
     MOVE WS-WY TO WS-CY

     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 2
         IF WS-ROUND = 1
             MOVE 0 TO WS-WITH-ON
             MOVE "Use Item only:" TO WS-TAG
         ELSE
             MOVE 1 TO WS-WITH-ON
             MOVE "Use Item On then Use Item:" TO WS-TAG
         END-IF
    *>   Water bucket: the source goes into the cell before the wall.
         COMPUTE WS-CZ = WS-BZ + 7
         MOVE WS-WATER-BUCKET TO WS-HOLD
         PERFORM CLICK
         MOVE WS-WATER TO WS-WANT-STATE
         MOVE WS-BUCKET TO WS-WANT-ITEM
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: a water bucket used on a wall places a water source before it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL

    *>   Empty bucket: the source is picked up.
         MOVE WS-BUCKET TO WS-HOLD
         PERFORM CLICK
         MOVE 0 TO WS-WANT-STATE
         MOVE WS-WATER-BUCKET TO WS-WANT-ITEM
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: an empty bucket picks up the water source ahead" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL

    *>   Lava bucket.
         MOVE WS-LAVA-BUCKET TO WS-HOLD
         PERFORM CLICK
         MOVE WS-LAVA TO WS-WANT-STATE
         MOVE WS-BUCKET TO WS-WANT-ITEM
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: a lava bucket used on a wall places a lava source before it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL
         MOVE WS-BUCKET TO WS-HOLD
         PERFORM CLICK
         MOVE 0 TO WS-WANT-STATE
         MOVE WS-LAVA-BUCKET TO WS-WANT-ITEM
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: an empty bucket picks up the lava source ahead" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL

     END-PERFORM

*>   A waterlogged fence (a block that holds a water source): the empty bucket takes the water and the fence stays, dry; the water bucket waterlogs a dry fence.
     MOVE "oak_fence" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-FENCE-DRY
     MOVE "true" TO WS-PTEXT
     CALL "BLOCK-STATE-PROP" USING WS-PMODE WS-FENCE-DRY WS-PROP WS-PTEXT WS-FENCE-WET
     MOVE "kelp" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-KELP
     MOVE 1 TO WS-WITH-ON
     MOVE "Use Item On then Use Item:" TO WS-TAG
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-FENCE-WET
     MOVE WS-WZ TO WS-CZ
     MOVE WS-BUCKET TO WS-HOLD
     PERFORM CLICK
     MOVE WS-FENCE-DRY TO WS-WANT-STATE
     MOVE WS-WATER-BUCKET TO WS-WANT-ITEM
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: an empty bucket takes the water of a waterlogged fence and leaves the fence" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-CELL
     MOVE WS-WATER-BUCKET TO WS-HOLD
     PERFORM CLICK
     MOVE WS-FENCE-WET TO WS-WANT-STATE
     MOVE WS-BUCKET TO WS-WANT-ITEM
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: a water bucket waterlogs a dry fence it is aimed at" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-CELL
*>   Kelp holds water but gives none to a bucket: nothing changes.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-KELP
     MOVE WS-BUCKET TO WS-HOLD
     PERFORM CLICK
     MOVE WS-KELP TO WS-WANT-STATE
     MOVE WS-BUCKET TO WS-WANT-ITEM
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-TAG) " acceptance bugfountain: an empty bucket aimed at kelp takes nothing" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-CELL

*>   Real terrain, the bucket aimed straight down at the ground (survival, then creative): the cell above the ground takes the water, and the empty bucket takes it back.
     COMPUTE WS-CX = WS-BX + 20
     COMPUTE WS-CZ = WS-BZ + 20
     MOVE 200 TO WS-GY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-GY WS-CZ WS-GROUND
     PERFORM VARYING WS-GY FROM 200 BY -1 UNTIL WS-GY < 0 OR WS-GROUND NOT = 0
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-GY WS-CZ WS-GROUND
     END-PERFORM
     MOVE WS-GY TO WS-CY
     COMPUTE WS-E = WS-GY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-E WS-CZ WS-AIR
     COMPUTE WS-E = WS-GY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-E WS-CZ WS-AIR
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-GY + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     COMPUTE WS-CY = WS-GY + 1
     PERFORM VARYING WS-MODE FROM 0 BY 1 UNTIL WS-MODE > 1
         MOVE WS-MODE TO PL-MODE(WS-PLAYER) WS-MODE-TEXT
         MOVE WS-WATER-BUCKET TO WS-HOLD
         PERFORM AIMED-CLICK
         MOVE WS-WATER TO WS-WANT-STATE
         MOVE WS-BUCKET TO WS-WANT-ITEM
         IF WS-MODE = 1
             MOVE WS-WATER-BUCKET TO WS-WANT-ITEM
         END-IF
         MOVE SPACES TO WS-CASE
         STRING "terrain, mode " WS-MODE-TEXT ": acceptance bugfountain: a water bucket aimed down at the ground places a water source on it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL
         MOVE WS-BUCKET TO WS-HOLD
         PERFORM AIMED-CLICK
         MOVE 0 TO WS-WANT-STATE
         MOVE WS-WATER-BUCKET TO WS-WANT-ITEM
         IF WS-MODE = 1
             MOVE WS-BUCKET TO WS-WANT-ITEM
         END-IF
         MOVE SPACES TO WS-CASE
         STRING "terrain, mode " WS-MODE-TEXT ": acceptance bugfountain: an empty bucket aimed down at the water takes it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-CELL
     END-PERFORM
     STOP RUN.

*> The client's right click on the wall: Use Item On (face 2, north) and then Use Item with the held bucket WS-HOLD (one in slot 1).
 AIMED-CLICK.
     MOVE WS-HOLD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     CALL "AIM-USE-ITEM" USING WS-CONN WS-PITCH
     CALL "TEST-TICKS" USING WS-TICKS.

 CLICK.
     MOVE WS-HOLD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     IF WS-WITH-ON = 1
         CALL "TEST-USE-ON" USING WS-CONN WS-WX WS-WY WS-WZ WS-FACE WS-SEQ
     END-IF
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "TEST-TICKS" USING WS-TICKS.

*> The block at WS-CX, WS-CY, WS-CZ is WS-WANT-STATE and slot 1 holds WS-WANT-ITEM.
 CHECK-CELL.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-PLAYER, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-WANT-STATE TO WS-E1
     MOVE WS-WANT-ITEM TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

 FIND-ITEM.
     MOVE WS-ITEM-KEY TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS.
 END PROGRAM ACC-BUGFOUNTAIN-BUCKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIM-USE-ITEM.
*> USING connection id, pitch (FLOAT-SHORT): Use Item (0x43), main hand, sequence 0, yaw 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 67.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ID L-PITCH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-YAW
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PITCH
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM AIM-USE-ITEM.

 COPY CORETEST.
 COPY CMDTEST.
