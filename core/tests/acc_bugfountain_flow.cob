*> Acceptance test, lane bugfountain (operator report try15: "the fountain in the stronghold doesn't flow"; docs/protocol/36-structures-1 section 6.5 placeBlock "if the position now has a
*> non-empty fluid state, schedule a fluid tick for it with delay 0", 10 section 9 aquifer fluid cells post-processed, 29a section 2): a standard world opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it), seed 12345. The chunks around the nearest stronghold are generated; every water or lava cell that can
*> spread (the cell below or a cell beside it, inside its chunk, holds no fluid and has no collision) has a pending fluid tick the moment the chunk is installed, and running the world spreads the
*> fountain of the RoomCrossing (water on a pillar, 36-5 section 4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFOUNTAIN-FLOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FLUIDS              BINARY-LONG.
 01 WS-SOURCES             BINARY-LONG.
 01 WS-PENDING             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-HAS                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FOUNTAINS           BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-FAR                 BINARY-LONG VALUE 60.
 01 WS-FAR-Z               BINARY-LONG VALUE 60.
 01 WS-NAME-PL             PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "acceptance bugfountain flow no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "BugFountain" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     MOVE "strongholds" TO WS-NAME
     MOVE 0 TO WS-OX WS-OY WS-OZ
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME CW-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-SX WS-SZ WS-LX WS-LY WS-LZ
     MOVE 0 TO WS-FLUIDS WS-SOURCES WS-PENDING WS-FOUNTAINS
     PERFORM VARYING WS-CZ FROM WS-SZ BY 1 UNTIL WS-CZ > WS-SZ + 3
         PERFORM VARYING WS-CX FROM WS-SX BY 1 UNTIL WS-CX > WS-SX + 3
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
             PERFORM SCAN-CHUNK
         END-PERFORM
     END-PERFORM
     MOVE "acceptance bugfountain flow: the stronghold chunks hold fluid cells that can spread" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SOURCES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugfountain flow: every generated fluid cell that can spread has a pending fluid tick" TO TL-CASE
     MOVE WS-SOURCES TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The fountain of the RoomCrossing (36-5): a pillar of stone with a water source on top, in a room of air, in a chunk far from the others. The cells are written as the generator writes
*>   them (no block change, so no hook), then the chunk post-processing runs: the source has a tick, and the water runs over the pillar's edge.
     CALL "TEST-JOIN-OP" USING WS-NAME-PL WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     COMPUTE PL-X(WS-PLAYER) = WS-FAR * 16 + 5.5
     COMPUTE PL-Y(WS-PLAYER) = 101
     COMPUTE PL-Z(WS-PLAYER) = WS-FAR * 16 + 5.5
     MOVE WS-FAR TO PL-CENTER-X(WS-PLAYER) PL-CENTER-Z(WS-PLAYER)
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-FAR WS-FAR-Z WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "CHUNK-FLUID-POST" USING WS-ROW WS-BEFORE
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     COMPUTE WS-LY = 100 - DM-MIN-Y(WS-DIM)
     PERFORM VARYING WS-Z FROM 4 BY 1 UNTIL WS-Z > 12
         PERFORM VARYING WS-X FROM 4 BY 1 UNTIL WS-X > 12
             COMPUTE WS-I = WS-LY * 256 + WS-Z * 16 + WS-X + 1
             MOVE WS-STONE TO CE-STATE(WS-I)
             PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 6
                 COMPUTE WS-I = (WS-LY + WS-Y) * 256 + WS-Z * 16 + WS-X + 1
                 MOVE 0 TO CE-STATE(WS-I)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 3
         COMPUTE WS-I = (WS-LY + WS-Y) * 256 + 8 * 16 + 8 + 1
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     COMPUTE WS-I = (WS-LY + 4) * 256 + 8 * 16 + 8 + 1
     MOVE WS-WATER-FIRST TO CE-STATE(WS-I)
     CALL "CHUNK-FLUID-POST" USING WS-ROW WS-TICKS
     COMPUTE WS-ADDED = WS-TICKS - WS-BEFORE
     MOVE "acceptance bugfountain flow: the post-processing schedules a tick for the fountain's water source" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ADDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = 60 * 16 + 8
     COMPUTE WS-Z = 60 * 16 + 8
     COMPUTE WS-Y = 104
     MOVE 1 TO WS-KIND
     CALL "BT-HAS" USING WS-DIM WS-TYPE WS-KIND WS-X WS-Y WS-Z WS-HAS
     MOVE "acceptance bugfountain flow: the fountain's water source holds a pending fluid tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-X = 60 * 16 + 9
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance bugfountain flow: after the ticks the water has spread beside the pillar's top" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WATER
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Y = 101
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance bugfountain flow: after the ticks the water has run down to the floor" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WATER
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The default state of the block WS-KEY.
 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

*> Chunk row WS-ROW: the water and lava cells (WS-FLUIDS), those with a spreadable neighbour in the chunk (WS-SOURCES) and how many of those hold a pending fluid tick (WS-PENDING).
 SCAN-CHUNK.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELLS = DM-HEIGHT(WS-DIM) * 256
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE CB-S-BLOCK(CE-STATE(WS-I) + 1) TO WS-BLOCK
         IF WS-BLOCK = WS-WATER OR WS-BLOCK = WS-LAVA
             ADD 1 TO WS-FLUIDS
             COMPUTE WS-R = FUNCTION MOD(WS-I - 1, 256)
             COMPUTE WS-Y = (WS-I - 1 - WS-R) / 256
             COMPUTE WS-Z = (WS-R - FUNCTION MOD(WS-R, 16)) / 16
             COMPUTE WS-X = FUNCTION MOD(WS-R, 16)
             IF WS-Y > 0 AND WS-X > 0 AND WS-X < 15 AND WS-Z > 0 AND WS-Z < 15
                 IF CE-STATE(WS-I - 256) = 0 OR CE-STATE(WS-I - 1) = 0 OR CE-STATE(WS-I + 1) = 0
                         OR CE-STATE(WS-I - 16) = 0 OR CE-STATE(WS-I + 16) = 0
                     ADD 1 TO WS-SOURCES
                     COMPUTE WS-X = WS-CX * 16 + WS-X
                     COMPUTE WS-Z = WS-CZ * 16 + WS-Z
                     COMPUTE WS-Y = WS-Y + DM-MIN-Y(WS-DIM)
                     MOVE 2 TO WS-KIND
                     IF WS-BLOCK = WS-WATER
                         MOVE 1 TO WS-KIND
                     END-IF
                     CALL "BT-HAS" USING WS-DIM WS-TYPE WS-KIND WS-X WS-Y WS-Z WS-HAS
                     ADD WS-HAS TO WS-PENDING
                 END-IF
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGFOUNTAIN-FLOW.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
