*> Chunk payloads and the initial chunk batch (docs/protocol/06-chunk-format.md;
*> docs/protocol/09-cobolcraft-profile.md §3.2, §3.4 rules 1 and 2). Packet builders append the
*> packet id and body to the caller's PB-BUFFER (contracts/proto-api.md §5), ready for CORE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-HEIGHTMAP.
*> USING cache row, Long count out (BINARY-LONG), Longs out (table of 256 BINARY-DOUBLE UNSIGNED):
*> the heightmap of the chunk (06 §3.1), shared by Level Chunk With Light and the on-disk chunk
*> (07 §7 Heightmaps): per column z * 16 + x the topmost non-void Y + 1 - min Y, ceillog2(height + 1)
*> bits per entry, floor(64 / bits) entries per Long, no entry spanning two Longs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MULS.
    05 WS-MUL              BINARY-DOUBLE UNSIGNED OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LONGS                BINARY-LONG.
 01 L-HEIGHTMAP.
    05 L-HM                BINARY-DOUBLE UNSIGNED OCCURS 256 TIMES.
 PROCEDURE DIVISION USING L-ROW L-LONGS L-HEIGHTMAP.
     MOVE 0 TO WS-BITS
     MOVE 1 TO WS-RANGE
     PERFORM UNTIL WS-RANGE >= DM-HEIGHT(CK-DIM(L-ROW)) + 1
         ADD 1 TO WS-BITS
         COMPUTE WS-RANGE = WS-RANGE * 2
     END-PERFORM
     COMPUTE WS-PER-LONG = 64 / WS-BITS
     COMPUTE L-LONGS = (256 + WS-PER-LONG - 1) / WS-PER-LONG
     MOVE 1 TO WS-MUL(1)
     PERFORM VARYING WS-SLOT FROM 2 BY 1 UNTIL WS-SLOT > WS-PER-LONG
         COMPUTE WS-MUL(WS-SLOT) = WS-MUL(WS-SLOT - 1) * WS-RANGE
     END-PERFORM
     CALL "WORLD-COLUMN-TOPS" USING L-ROW WS-TOPS
     INITIALIZE L-HEIGHTMAP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-K = WS-I / WS-PER-LONG
         COMPUTE WS-SLOT = WS-I - WS-K * WS-PER-LONG
         COMPUTE L-HM(WS-K + 1) = L-HM(WS-K + 1) + (WS-TOP(WS-I + 1) + 1) * WS-MUL(WS-SLOT + 1)
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-HEIGHTMAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-PACKET-BUILD.
*> USING dim, chunk x, chunk z (BINARY-LONG), PB-BUFFER: appends Level Chunk With Light (0x2E) for
*> that chunk, generated and lit on first access (WORLD-CHUNK), through PB-PUT-CHUNK-24 (06 §2 to §7):
*> as many sections as the dimension has (height / 16), the block states and biomes of the cell layout
*> (CELLS.cpy), the global palette bits of the dimension row, no block entities and no fluid counts.
*> Heightmaps WORLD_SURFACE (1), MOTION_BLOCKING (4) and MOTION_BLOCKING_NO_LEAVES (5), identical:
*> the topmost non-void layer + 1 of each column (WORLD-COLUMN-TOPS), in ceillog2(height + 1) bits.
*> Light for every light section index 0 to section count + 1: an all-zero array is empty, every other
*> one an array; a dimension without sky light (DIM-LIGHT-BLOCK-ONLY, §15.3) sets no sky light bit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 46.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-LIGHTS              BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-MASK                BINARY-LONG VALUE 50.
 01 WS-BLOCK-BITS          BINARY-LONG.
 01 WS-BIOME-BITS          BINARY-LONG.
 01 WS-BE-COUNT            BINARY-LONG VALUE 0.
 01 WS-BE-MAX              BINARY-LONG VALUE 64.
 01 WS-BE-DATA-MAX         BINARY-LONG VALUE 65536.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-WATER-END           BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-LAVA-END            BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NON-EMPTY           BINARY-LONG.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-HM-VALUES.
    05 WS-HM               BINARY-LONG OCCURS 1536 TIMES.
 01 WS-COUNTS.
    05 WS-COUNT-ENTRY      BINARY-LONG OCCURS 48 TIMES.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 98304 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 1536 TIMES.
 01 WS-BE-HEADS.
    05 WS-BE-HEAD          BINARY-LONG OCCURS 320 TIMES.
 01 WS-BE-DATA             PIC X(65536).
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 26 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 26 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY-X      PIC X(2048) OCCURS 26 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY-X    PIC X(2048) OCCURS 26 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER.
     CALL "WORLD-CHUNK" USING L-DIM L-CX L-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE L-CX TO WS-X
     MOVE L-CZ TO WS-Z
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     MOVE DM-BLOCK-BITS(L-DIM) TO WS-BLOCK-BITS
     MOVE DM-BIOME-BITS(L-DIM) TO WS-BIOME-BITS
*>   Heightmaps: ceillog2(height + 1) bits, three types with the same values.
     MOVE 0 TO WS-BITS
     MOVE 1 TO WS-RANGE
     PERFORM UNTIL WS-RANGE >= DM-HEIGHT(L-DIM) + 1
         ADD 1 TO WS-BITS
         COMPUTE WS-RANGE = WS-RANGE * 2
     END-PERFORM
     CALL "WORLD-COLUMN-TOPS" USING WS-ROW WS-TOPS
     INITIALIZE WS-HM-VALUES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-HM(256 + WS-I) = WS-TOP(WS-I) + 1
         COMPUTE WS-HM(1024 + WS-I) = WS-TOP(WS-I) + 1
         COMPUTE WS-HM(1280 + WS-I) = WS-TOP(WS-I) + 1
     END-PERFORM
*>   States, biomes and the non-empty count of each section.
     COMPUTE WS-CELLS = WS-SECTIONS * 4096
     INITIALIZE WS-COUNTS
     MOVE 0 TO WS-WATER-FIRST WS-WATER-END WS-LAVA-FIRST WS-LAVA-END
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I)(1:CB-KEY-LENGTH(WS-I)) = "minecraft:water"
             MOVE CB-FIRST-STATE(WS-I) TO WS-WATER-FIRST
             COMPUTE WS-WATER-END = CB-FIRST-STATE(WS-I) + CB-STATES(WS-I)
         END-IF
         IF CB-KEY(WS-I)(1:CB-KEY-LENGTH(WS-I)) = "minecraft:lava"
             MOVE CB-FIRST-STATE(WS-I) TO WS-LAVA-FIRST
             COMPUTE WS-LAVA-END = CB-FIRST-STATE(WS-I) + CB-STATES(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE CE-STATE(WS-I) TO WS-STATE(WS-I)
         IF WS-STATE(WS-I) NOT = 0
             COMPUTE WS-S = (WS-I - 1) / 4096
             ADD 1 TO WS-COUNT-ENTRY(WS-S * 2 + 1)
*>           the fluid count: every state of water and of lava (waterlogged states are not counted)
             IF (WS-STATE(WS-I) >= WS-WATER-FIRST AND WS-STATE(WS-I) < WS-WATER-END)
                 OR (WS-STATE(WS-I) >= WS-LAVA-FIRST AND WS-STATE(WS-I) < WS-LAVA-END)
                 ADD 1 TO WS-COUNT-ENTRY(WS-S * 2 + 2)
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-CELLS = WS-SECTIONS * 64
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE CE-BIOME(WS-I) TO WS-BIOME(WS-I)
     END-PERFORM
*>   Light: the arrays go to the wire unchanged (06 §7.1).
     INITIALIZE WS-SKY-STATES WS-BLOCK-STATES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIGHTS
         COMPUTE WS-BYTE = (WS-I - 1) * 2048 + 1
         EVALUATE TRUE
             WHEN DM-LIGHT-POLICY(L-DIM) = DIM-LIGHT-BLOCK-ONLY
                 MOVE 0 TO WS-SKY-STATE(WS-I)
             WHEN CE-SKYS(WS-BYTE:2048) = LOW-VALUES
                 MOVE 1 TO WS-SKY-STATE(WS-I)
             WHEN OTHER
                 MOVE 2 TO WS-SKY-STATE(WS-I)
                 MOVE CE-SKYS(WS-BYTE:2048) TO WS-SKY-ARRAY-X(WS-I)
         END-EVALUATE
         IF CE-BLOCK-LIGHTS(WS-BYTE:2048) = LOW-VALUES
             MOVE 1 TO WS-BLOCK-STATE(WS-I)
         ELSE
             MOVE 2 TO WS-BLOCK-STATE(WS-I)
             MOVE CE-BLOCK-LIGHTS(WS-BYTE:2048) TO WS-BLOCK-ARRAY-X(WS-I)
         END-IF
     END-PERFORM
     CALL "BE-CHUNK-PACKET" USING L-DIM L-CX L-CZ WS-BE-COUNT WS-BE-HEADS WS-BE-DATA
     CALL "PB-PUT-CHUNK-24" USING PB-BUFFER WS-X WS-Z WS-SECTIONS WS-BITS WS-MASK WS-HM-VALUES
         WS-COUNTS WS-STATES WS-BIOMES WS-BLOCK-BITS WS-BIOME-BITS WS-BE-COUNT WS-BE-HEADS
         WS-BE-DATA WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES WS-BLOCK-ARRAYS
     GOBACK.
 END PROGRAM CHUNK-PACKET-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-BATCH-START-BUILD.
*> USING PB-BUFFER: appends Chunk Batch Start (0x0C, no fields).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 12.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     GOBACK.
 END PROGRAM CHUNK-BATCH-START-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-BATCH-FINISHED-BUILD.
*> USING count (BINARY-LONG), PB-BUFFER: appends Chunk Batch Finished (0x0B, VarInt batch size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 11.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     GOBACK.
 END PROGRAM CHUNK-BATCH-FINISHED-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-CACHE-CENTER-BUILD.
*> USING chunk x, chunk z (BINARY-LONG), PB-BUFFER: appends Set Chunk Cache Center (0x60, two
*> VarInts).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 96.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CX
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CZ
     GOBACK.
 END PROGRAM CHUNK-CACHE-CENTER-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNKS-INITIAL-BATCH.
*> USING connection id (BINARY-LONG) of a connection with a player (CN-PLAYER): sends Set Chunk
*> Cache Center with the chunk of the player's feet (floor(PL-X / 16), floor(PL-Z / 16)), then one
*> batch: Chunk Batch Start, Level Chunk With Light for every chunk of the player's dimension within
*> the configured view distance d (CS-VIEW-DISTANCE) of that chunk, Chunk Batch Finished with their
*> count. Center first, as the 09 §3.2 join sequence orders it: the client keeps only chunks inside
*> the view of its cache center. "Within view distance" is the square of (2d + 1) x (2d + 1)
*> chunks around the center (Chebyshev distance <= d), sent ring by ring outward from the center
*> (ring r: max(|dx|, |dz|) = r); inside a ring by dz ascending, then dx ascending. Sets
*> PL-CENTER-X/Z and adds 1 to PL-BATCH-PENDING (the batch awaits Chunk Batch Received).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FEED                BINARY-LONG.
 COPY PROTO.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-CACHE-CENTER-BUILD" USING WS-CX WS-CZ PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "CHUNK-FEED-ON" USING WS-DIM WS-FEED
     IF WS-FEED = 1
*>       the dimension's chunks come from the generation queue: the feed sends them as they are done (core/src/chunk-feed.cob)
         CALL "CHUNK-FEED-RESET" USING WS-PLAYER WS-CX WS-CZ
         MOVE WS-CX TO PL-CENTER-X(WS-PLAYER)
         MOVE WS-CZ TO PL-CENTER-Z(WS-PLAYER)
         GOBACK
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-START-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > CS-VIEW-DISTANCE
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > WS-R * 2
             MOVE 1 TO WS-STEP
             IF WS-DZ > 0 AND WS-DZ < WS-R * 2
                 COMPUTE WS-STEP = WS-R * 2
             END-IF
             PERFORM VARYING WS-DX FROM 0 BY WS-STEP UNTIL WS-DX > WS-R * 2
                 COMPUTE WS-X = WS-CX + WS-DX - WS-R
                 COMPUTE WS-Z = WS-CZ + WS-DZ - WS-R
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-X WS-Z PB-BUFFER
                 CALL "CORE-SEND" USING L-ID PB-BUFFER
                 ADD 1 TO WS-COUNT
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-FINISHED-BUILD" USING WS-COUNT PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE WS-CX TO PL-CENTER-X(WS-PLAYER)
     MOVE WS-CZ TO PL-CENTER-Z(WS-PLAYER)
     ADD 1 TO PL-BATCH-PENDING(WS-PLAYER)
     GOBACK.
 END PROGRAM CHUNKS-INITIAL-BATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORGET-CHUNK-BUILD.
*> USING chunk x, chunk z (BINARY-LONG), PB-BUFFER: appends Forget Level Chunk (0x26, 05a; 00 §4.2
*> ChunkPos: one Long, chunk x in the low 32 bits, chunk z in the high 32 bits).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 38.
 01 WS-TWO-32              BINARY-DOUBLE VALUE 4294967296.
 01 WS-POS                 BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ PB-BUFFER.
     COMPUTE WS-POS = L-CZ * WS-TWO-32 + FUNCTION MOD(L-CX, WS-TWO-32)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-POS
     GOBACK.
 END PROGRAM FORGET-CHUNK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNKS-FOLLOW.
*> USING connection id (BINARY-LONG) of a player who moved (US3-4; 09 §3.2 Set Chunk Cache Center,
*> Forget Level Chunk, Level Chunk With Light rows). When the chunk of the player's feet differs
*> from the chunk cache center (PL-CENTER-X/Z): Set Chunk Cache Center with the new chunk; Forget
*> Level Chunk for every chunk of the old view square (Chebyshev distance <= the configured view
*> distance d of the old center) outside the new one; then one batch (Chunk Batch Start, Level
*> Chunk With Light for every chunk of the new square outside the old one, by z ascending then x
*> ascending, Chunk Batch Finished with their count; PL-BATCH-PENDING + 1). The new center is
*> stored and the entities the player sees are re-evaluated (ENTITY-VIEWER-REFRESH).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOW-X               BINARY-LONG.
 01 WS-LOW-Z               BINARY-LONG.
 01 WS-FEED                BINARY-LONG.
 COPY PROTO.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE CN-PLAYER(L-ID) TO WS-PLAYER
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     MOVE PL-CENTER-X(WS-PLAYER) TO WS-OX
     MOVE PL-CENTER-Z(WS-PLAYER) TO WS-OZ
     IF WS-CX = WS-OX AND WS-CZ = WS-OZ
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE CS-VIEW-DISTANCE TO WS-D
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-CACHE-CENTER-BUILD" USING WS-CX WS-CZ PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     COMPUTE WS-LOW-X = WS-OX - WS-D
     COMPUTE WS-LOW-Z = WS-OZ - WS-D
     PERFORM VARYING WS-Z FROM WS-LOW-Z BY 1 UNTIL WS-Z > WS-OZ + WS-D
         PERFORM VARYING WS-X FROM WS-LOW-X BY 1 UNTIL WS-X > WS-OX + WS-D
             IF FUNCTION ABS(WS-X - WS-CX) > WS-D OR FUNCTION ABS(WS-Z - WS-CZ) > WS-D
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "FORGET-CHUNK-BUILD" USING WS-X WS-Z PB-BUFFER
                 CALL "CORE-SEND" USING L-ID PB-BUFFER
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "CHUNK-FEED-ON" USING WS-DIM WS-FEED
     IF WS-FEED = 1
*>       the new chunks come from the generation queue through the feed (the forgets above are sent now)
         CALL "CHUNK-FEED-MOVE" USING WS-PLAYER WS-CX WS-CZ
         MOVE WS-CX TO PL-CENTER-X(WS-PLAYER)
         MOVE WS-CZ TO PL-CENTER-Z(WS-PLAYER)
         CALL "ENTITY-VIEWER-REFRESH" USING WS-PLAYER
         CALL "CHUNKS-UNLOAD"
         GOBACK
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-START-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE 0 TO WS-COUNT
     COMPUTE WS-LOW-X = WS-CX - WS-D
     COMPUTE WS-LOW-Z = WS-CZ - WS-D
     PERFORM VARYING WS-Z FROM WS-LOW-Z BY 1 UNTIL WS-Z > WS-CZ + WS-D
         PERFORM VARYING WS-X FROM WS-LOW-X BY 1 UNTIL WS-X > WS-CX + WS-D
             IF FUNCTION ABS(WS-X - WS-OX) > WS-D OR FUNCTION ABS(WS-Z - WS-OZ) > WS-D
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-X WS-Z PB-BUFFER
                 CALL "CORE-SEND" USING L-ID PB-BUFFER
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-FINISHED-BUILD" USING WS-COUNT PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE WS-CX TO PL-CENTER-X(WS-PLAYER)
     MOVE WS-CZ TO PL-CENTER-Z(WS-PLAYER)
     ADD 1 TO PL-BATCH-PENDING(WS-PLAYER)
     CALL "ENTITY-VIEWER-REFRESH" USING WS-PLAYER
     CALL "CHUNKS-UNLOAD"
     GOBACK.
 END PROGRAM CHUNKS-FOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNKS-UNLOAD.
*> No parameters (called after a player's chunk cache center moved): every loaded chunk that is
*> outside the view square (Chebyshev distance <= the view distance from the chunk cache center) of
*> every player in its dimension leaves the chunk cache: a changed chunk is first written to its
*> region file (PERSIST-CHUNK-SAVE, 07 §9.5), so it reads back the same when next used; an
*> unchanged one is generated again then (WORLD-CHUNK-LOAD).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
         IF CK-USED(WS-ROW) = 1
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
                     OR WS-SEEN = 1
                 IF PL-USED(WS-PLAYER) = 1 AND PL-DIM(WS-PLAYER) = CK-DIM(WS-ROW)
                         AND FUNCTION ABS(CK-X(WS-ROW) - PL-CENTER-X(WS-PLAYER)) <= CS-VIEW-DISTANCE
                         AND FUNCTION ABS(CK-Z(WS-ROW) - PL-CENTER-Z(WS-PLAYER)) <= CS-VIEW-DISTANCE
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 IF CK-CHANGED(WS-ROW) = 1
                     CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
                 END-IF
                 CALL "WORLD-CHUNK-RELEASE" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNKS-UNLOAD.
