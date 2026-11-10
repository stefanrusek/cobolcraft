*> Test of the block entities in the live world (core/src/be-world.cob; docs/protocol/31-block-entities-1 sections 2.3, 5.3, 6, 9.2 and
*> 29 section 12; US12): a block set in the world creates the block entity of its type and removes it with the block (the contents of
*> a removed container become ground items), a state change inside the same block keeps it, the entities of a chunk are written into
*> block_entities of the saved chunk and read back with their items (and component patches) when the world is reopened, and the Level
*> Chunk packet lists them with their type and position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CSTACK.
 COPY PROTO.
 COPY CHUNK24TAB.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 8.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-STATE               BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ITEM                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-BYTE                BINARY-LONG.
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-KEY24               PIC X(24).
 01 WS-LEN24               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NEG                 BINARY-LONG VALUE -1.
 01 WS-FAR                 BINARY-LONG VALUE 3000.
 01 WS-FAR2               BINARY-LONG VALUE 3000.
 01 WS-HIGH                BINARY-LONG VALUE 9999.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG VALUE 1.
 01 WS-THREE2              BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     MOVE "T" TO TL-MODE

     MOVE "test be world a chest set in the world creates a chest block entity (type 1) at its position, a barrel type 26, "
         & "an ender chest 3, a shulker box 24" TO TL-CASE
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE WS-BE TO WS-BE2
     MOVE 9 TO WS-X
     MOVE "minecraft:barrel" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE BE-TYPE(WS-BE2) TO WS-E1
     MOVE BE-TYPE(WS-BE) TO WS-E2
     MOVE 10 TO WS-X
     MOVE "minecraft:ender_chest" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE BE-TYPE(WS-BE) TO WS-E3
     MOVE 11 TO WS-X
     MOVE "minecraft:red_shulker_box" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE BE-TYPE(WS-BE) TO WS-E4
     MOVE BE-DIM(WS-BE) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " dim "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 26 3 24 dim 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a block that has no block entity type (greystone) creates none and a chest changed to another state of "
         & "the same block keeps its entity" TO TL-CASE
     MOVE 8 TO WS-X
     MOVE 71 TO WS-Y
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-E1
     MOVE 70 TO WS-Y
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     ADD 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-ID
     MOVE SPACES TO WS-TEXT
     MOVE WS-ID TO WS-E2
     IF WS-ID = WS-BE AND WS-BE > 0
         MOVE "same" TO WS-TEXT
     ELSE
         MOVE "different" TO WS-TEXT
     END-IF
     STRING "none " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO WS-TEXT
     MOVE "none 0 same" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world removing the chest (state 0) frees its entity and drops its contents as a ground item with the stack "
         & "and its count" TO TL-CASE
     MOVE 5 TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 7 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE BE-USED(WS-BE) TO WS-E1
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = 5
             ADD EN-ITEM-COUNT(WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "used " FUNCTION TRIM(WS-E1) " dropped " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "used 0 dropped 7" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a chest holding a named stack saved with the world and loaded again after reopening has the entity at the "
         & "same position, the item, the count and the stack's custom name" TO TL-CASE
     MOVE 8 TO WS-X
     MOVE 70 TO WS-Y
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE 6 TO BE-SLOT-ITEM(WS-BE, 5)
     MOVE 12 TO BE-SLOT-COUNT(WS-BE, 5)
     MOVE 0 TO WS-HANDLE
     MOVE "Treasure" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     MOVE WS-HANDLE TO BE-SLOT-VAR(WS-BE, 5)
     CALL "BE-MARK-CHUNK" USING WS-BE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "TEST-ADD-CONTAINERS"
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE SPACES TO WS-NAME
     IF WS-BE = 0
         MOVE "no entity before the chunk is loaded" TO WS-TEXT
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE BE-TYPE(WS-BE) TO WS-E1
     MOVE BE-SLOT-ITEM(WS-BE, 5) TO WS-E2
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-E3
     MOVE BE-SLOT-VAR(WS-BE, 5) TO WS-HANDLE
     CALL "SP-GET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3) " " WS-NAME(1:WS-NAME-LENGTH)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 6x12 Treasure" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world the Level Chunk packet of the chunk lists the four containers of the chunk, the chest (type 1) first with its local x, y, z"
         TO TL-CASE
     PERFORM SET-GEOMETRY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-ZERO WS-ZERO2 PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-MAX CH-BE-DATA-MAX
         CH-BE-COUNT CH-BE-HEADS CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES
         CH-BLK-ARRAYS
     MOVE CH-BE-COUNT TO WS-E1
     MOVE CH-BE-HEAD(1) TO WS-E2
     MOVE CH-BE-HEAD(2) TO WS-E3
     MOVE CH-BE-HEAD(3) TO WS-E4
     MOVE CH-BE-HEAD(4) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "count " FUNCTION TRIM(WS-E1) " at " FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "," FUNCTION TRIM(WS-E4)
         " type " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "count 4 at 8,70,8 type 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a chunk of another position without containers lists none in its packet" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-THREE WS-THREE2 PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-MAX CH-BE-DATA-MAX
         CH-BE-COUNT CH-BE-HEADS CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES
         CH-BLK-ARRAYS
     MOVE CH-BE-COUNT TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "count " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "count 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a bell (a table key without a namespace) gets the bell block entity, and a banner's packet entry carries a "
         & "tag (data length above 0) while a chest's carries none" TO TL-CASE
     MOVE 12 TO WS-X
     MOVE "bell" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE "bell" TO WS-KEY24
     MOVE 4 TO WS-LEN24
     CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN24 WS-TYPE
     MOVE BE-TYPE(WS-BE) TO WS-E1
     MOVE WS-TYPE TO WS-E2
     MOVE 13 TO WS-X
     MOVE "white_banner" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE BE-TYPE(WS-BE) TO WS-E3
     PERFORM SET-GEOMETRY
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-ZERO WS-ZERO2 PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-MAX CH-BE-DATA-MAX
         CH-BE-COUNT CH-BE-HEADS CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES
         CH-BLK-ARRAYS
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= CH-BE-COUNT
         IF CH-BE-HEAD(WS-I * 5 + 4) = 20 AND CH-BE-HEAD(WS-I * 5 + 5) > 0
             ADD 1 TO WS-COUNT
         END-IF
         IF CH-BE-HEAD(WS-I * 5 + 4) = 1 AND CH-BE-HEAD(WS-I * 5 + 5) > 0
             ADD 10 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "bell " FUNCTION TRIM(WS-E1) "=" FUNCTION TRIM(WS-E2) " banner " FUNCTION TRIM(WS-E3) " tagged " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "bell " FUNCTION TRIM(WS-E2) "=" FUNCTION TRIM(WS-E2) " banner 20 tagged 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world an invalid block id or state has no type, no key and no family" TO TL-CASE
     CALL "BE-BLOCK-TYPE" USING WS-NEG WS-TYPE
     MOVE WS-TYPE TO WS-E1
     CALL "BE-BLOCK-KEY" USING WS-NEG WS-KEY WS-LEN24
     MOVE WS-LEN24 TO WS-E2
     CALL "BE-STATE-FIELDS" USING WS-NEG WS-FAMILY WS-DIR WS-CTYPE WS-FLAG
     MOVE WS-FAMILY TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "-1 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a left chest half with no partner removed leaves nothing to fix, an entity gone before its block is set to "
         & "air is no error, and setChanged of an entity in an unloaded chunk marks nothing" TO TL-CASE
     MOVE 1 TO WS-X
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM SET-BY-KEY
     COMPUTE WS-STATE = WS-STATE + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-E1
     MOVE 2 TO WS-X
     PERFORM SET-BY-KEY
     MOVE 0 TO BE-USED(WS-BE)
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE 3000 TO WS-CELL
     MOVE 15 TO WS-LEN24
     CALL "BE-CREATE" USING WS-DIM WS-FAR WS-Y WS-FAR2 WS-ONE WS-KEY WS-LEN24 WS-BE
     CALL "BE-MARK-CHUNK" USING WS-BE
     MOVE BE-CHANGED(WS-BE) TO WS-E2
     MOVE 0 TO BE-USED(WS-BE)
     MOVE SPACES TO WS-TEXT
     STRING "gone " FUNCTION TRIM(WS-E1) " changed " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "gone 0 changed 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a patch held by a chest slot survives SP-SWEEP, one held by nothing does not" TO TL-CASE
     MOVE 3 TO WS-X
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM SET-BY-KEY
     MOVE 0 TO WS-HANDLE
     MOVE "Kept" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     MOVE WS-HANDLE TO BE-SLOT-VAR(WS-BE, 1)
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 0 TO WS-ITEM
     MOVE "Lost" TO WS-NAME
     CALL "SP-SET-NAME" USING WS-ITEM WS-NAME WS-NAME-LENGTH
     CALL "SP-SWEEP"
     MOVE SP-LIVE(WS-HANDLE) TO WS-E1
     MOVE SP-LIVE(WS-ITEM) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "kept " FUNCTION TRIM(WS-E1) " lost " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "kept 1 lost 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world an entity whose block is gone from the cell and one above the world's height are dropped when the chunk is "
         & "read back, the chest beside them stays" TO TL-CASE
     MOVE 4 TO WS-X
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM SET-BY-KEY
     CALL "WORLD-FIND" USING WS-DIM WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE 0 TO CE-STATE(WS-CELL)
     MOVE 5 TO WS-X
     MOVE 15 TO WS-LEN24
     CALL "BE-CREATE" USING WS-DIM WS-X WS-HIGH WS-Z WS-ONE WS-KEY WS-LEN24 WS-BE
     CALL "BE-MARK-CHUNK" USING WS-BE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "TEST-ADD-CONTAINERS"
     MOVE 8 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-FLAG
     MOVE 4 TO WS-X
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-E2
     MOVE 5 TO WS-X
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-HIGH WS-Z WS-BE
     MOVE WS-BE TO WS-E3
     MOVE SPACES TO WS-TEXT
     IF WS-FLAG > 0
         MOVE "chest" TO WS-TEXT
     END-IF
     STRING FUNCTION TRIM(WS-TEXT) " void " FUNCTION TRIM(WS-E2) " high " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO WS-TEXT
     MOVE "chest void 0 high 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test be world a chunk that leaves the cache drops its entities (BE-CHUNK-DROP), those of other chunks stay" TO TL-CASE
     MOVE 8 TO WS-X
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-FLAG
     CALL "BE-CHUNK-DROP" USING WS-DIM WS-ZERO WS-ZERO2
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-E1
     MOVE WS-FLAG TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "before " FUNCTION TRIM(WS-E2) " after " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "before 1 after 0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

*> The reader's inputs for the dimension: its section count, the global palette bits and the heightmap bits ceillog2(height + 1).
 SET-GEOMETRY.
     COMPUTE CH-SECTIONS = DM-HEIGHT(WS-DIM) / 16
     MOVE DM-BLOCK-BITS(WS-DIM) TO CH-BLOCK-GBITS
     MOVE DM-BIOME-BITS(WS-DIM) TO CH-BIOME-GBITS
     MOVE 0 TO CH-HM-BITS
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I >= DM-HEIGHT(WS-DIM) + 1
         ADD 1 TO CH-HM-BITS
         COMPUTE WS-I = WS-I * 2
     END-PERFORM.

*> Sets the block of key WS-KEY (its default state) at WS-X, WS-Y, WS-Z and finds the entity there (WS-BE).
 SET-BY-KEY.
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-WORLD.

 COPY CORETEST.
 COPY BETEST.
