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
*> that chunk, generated and lit on first access (WORLD-CHUNK). Heightmaps WORLD_SURFACE (1),
*> MOTION_BLOCKING (4) and MOTION_BLOCKING_NO_LEAVES (5), identical (CHUNK-HEIGHTMAP). One section per 16 block layers through
*> CHUNK-SECTION-ENCODE (fluid count 0; biomes of WORLDGEN-DIM-BIOMES, the same for every cell Y). No
*> block entities. Light (LIGHT-ENCODE) for every light section index 0 to section count + 1: an
*> all-zero layer is empty, every other layer an array; the section below the world has no sky or
*> block light, the section above it sky light 15 and no block light (standin §5.2). A dimension
*> without sky light (DIM-LIGHT-BLOCK-ONLY, §15.3) sets no sky light bit in any mask.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BLOCKS.
 COPY CHUNKMEM.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SB-==.
 01 WS-SB-READY            PIC 9 VALUE 0.
 01 WS-SB-CAPACITY         BINARY-LONG VALUE 16384.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 46.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BLOCK-BITS          BINARY-LONG VALUE 5.
 01 WS-BIOME-BITS          BINARY-LONG VALUE 2.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MULS.
    05 WS-MUL              BINARY-DOUBLE UNSIGNED OCCURS 64 TIMES.
 01 WS-HEIGHTMAP.
    05 WS-HM               BINARY-DOUBLE UNSIGNED OCCURS 256 TIMES.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-NON-EMPTY           BINARY-LONG.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 4096 TIMES.
 01 WS-BIOME-COLUMNS.
    05 WS-BIOME-COLUMN     BINARY-LONG OCCURS 16 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIGHTS              BINARY-LONG.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 256 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 256 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY        OCCURS 18 TIMES.
       10 WS-SKY-BYTE      BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
 01 WS-SKY-ARRAYS-X REDEFINES WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY-X      PIC X(2048) OCCURS 18 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY      OCCURS 18 TIMES.
       10 WS-BLOCK-BYTE    BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
 01 WS-CELL                BINARY-LONG.
 01 WS-UNIFORM             BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-CACHE.
    05 WS-CACHE-ENTRY OCCURS 18 TIMES.
       10 WS-CACHE-LENGTH  BINARY-LONG.
       10 WS-CACHE-BYTES   PIC X(64).
 01 B-BYTES                PIC X BASED.
 01 B-SECTIONS             PIC X(1048576) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER.
     CALL "WORLD-CHUNK" USING L-DIM L-CX L-CZ WS-ROW
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(WS-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-INT" USING PB-BUFFER L-CX
     CALL "PB-PUT-INT" USING PB-BUFFER L-CZ
     CALL "CHUNK-HEIGHTMAP" USING WS-ROW WS-LONGS WS-HEIGHTMAP
     MOVE 3 TO WS-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     PERFORM VARYING WS-TYPE FROM 1 BY 1 UNTIL WS-TYPE > 5
         IF WS-TYPE = 1 OR WS-TYPE >= 4
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-LONGS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-LONGS
                 CALL "PB-PUT-LONG" USING PB-BUFFER WS-HM(WS-K)
             END-PERFORM
         END-IF
     END-PERFORM
*>   Section buffer (06 §3, §4), built apart to learn its length.
     IF WS-SB-READY = 0
         CALL "PB-INIT" USING SB-BUFFER WS-SB-CAPACITY
         MOVE 1 TO WS-SB-READY
     END-IF
     CALL "PB-RESET" USING SB-BUFFER
     CALL "WORLDGEN-DIM-BIOMES" USING L-DIM L-CX L-CZ WS-BIOME-COLUMNS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 63
         MOVE WS-BIOME-COLUMN(FUNCTION MOD(WS-I, 16) + 1) TO WS-BIOME(WS-I + 1)
     END-PERFORM
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     INITIALIZE WS-CACHE
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         COMPUTE WS-BASE = WS-S * 4096
*>       A section of one state (the region equals itself shifted by one cell) is encoded once per
*>       chunk and state; the next ones with that state repeat its bytes.
         IF CM-STATES(WS-BASE + 1:4095) = CM-STATES(WS-BASE + 2:4095)
             MOVE CM-STATE(WS-BASE + 1) TO WS-UNIFORM
             IF WS-CACHE-LENGTH(WS-UNIFORM + 1) > 0
                 CALL "PB-APPEND-BYTES" USING SB-BUFFER WS-CACHE-BYTES(WS-UNIFORM + 1)
                     WS-CACHE-LENGTH(WS-UNIFORM + 1)
             ELSE
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
                     MOVE WS-UNIFORM TO WS-STATE(WS-I)
                 END-PERFORM
                 MOVE 4096 TO WS-NON-EMPTY
                 IF WS-UNIFORM = ST-VOID
                     MOVE 0 TO WS-NON-EMPTY
                 END-IF
                 MOVE SB-LENGTH TO WS-START
                 CALL "CHUNK-SECTION-ENCODE" USING SB-BUFFER WS-NON-EMPTY WS-ZERO WS-STATES
                     WS-BIOMES WS-BLOCK-BITS WS-BIOME-BITS
                 SET ADDRESS OF B-SECTIONS TO SB-ADDR
                 COMPUTE WS-CACHE-LENGTH(WS-UNIFORM + 1) = SB-LENGTH - WS-START
                 MOVE B-SECTIONS(WS-START + 1:WS-CACHE-LENGTH(WS-UNIFORM + 1))
                     TO WS-CACHE-BYTES(WS-UNIFORM + 1)
             END-IF
         ELSE
             MOVE 0 TO WS-NON-EMPTY
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
                 MOVE CM-STATE(WS-BASE + WS-I) TO WS-STATE(WS-I)
                 IF WS-STATE(WS-I) NOT = ST-VOID
                     ADD 1 TO WS-NON-EMPTY
                 END-IF
             END-PERFORM
             CALL "CHUNK-SECTION-ENCODE" USING SB-BUFFER WS-NON-EMPTY WS-ZERO WS-STATES WS-BIOMES
                 WS-BLOCK-BITS WS-BIOME-BITS
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER SB-LENGTH
     SET ADDRESS OF B-BYTES TO SB-ADDR
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BYTES SB-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
*>   Light (06 §7; 09 §3.4 rule 2): index 1 is the section below the world, the last one above it.
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     MOVE 1 TO WS-SKY-STATE(1) WS-BLOCK-STATE(1) WS-BLOCK-STATE(WS-LIGHTS)
     MOVE 2 TO WS-SKY-STATE(WS-LIGHTS)
     MOVE ALL X"FF" TO WS-SKY-ARRAY-X(WS-LIGHTS)
     IF DM-LIGHT-POLICY(L-DIM) = DIM-LIGHT-BLOCK-ONLY
         MOVE 0 TO WS-SKY-STATE(1) WS-SKY-STATE(WS-LIGHTS)
     END-IF
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         COMPUTE WS-BASE = WS-S * 4096
         EVALUATE TRUE
             WHEN DM-LIGHT-POLICY(L-DIM) = DIM-LIGHT-BLOCK-ONLY
                 MOVE 0 TO WS-SKY-STATE(WS-S + 2)
             WHEN CM-SKYS(WS-BASE + 1:4096) = LOW-VALUES
                 MOVE 1 TO WS-SKY-STATE(WS-S + 2)
             WHEN CM-SKYS(WS-BASE + 1:4096) = ALL X"0F"
                 MOVE 2 TO WS-SKY-STATE(WS-S + 2)
                 MOVE ALL X"FF" TO WS-SKY-ARRAY-X(WS-S + 2)
             WHEN OTHER
                 MOVE 2 TO WS-SKY-STATE(WS-S + 2)
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
                     COMPUTE WS-CELL = WS-BASE + WS-I * 2 - 1
                     COMPUTE WS-SKY-BYTE(WS-S + 2, WS-I)
                         = CM-SKY(WS-CELL) + CM-SKY(WS-CELL + 1) * 16
                 END-PERFORM
         END-EVALUATE
         IF CM-BLOCKS(WS-BASE + 1:4096) = LOW-VALUES
             MOVE 1 TO WS-BLOCK-STATE(WS-S + 2)
         ELSE
             MOVE 2 TO WS-BLOCK-STATE(WS-S + 2)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
                 COMPUTE WS-CELL = WS-BASE + WS-I * 2 - 1
                 COMPUTE WS-BLOCK-BYTE(WS-S + 2, WS-I)
                     = CM-BLOCK(WS-CELL) + CM-BLOCK(WS-CELL + 1) * 16
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
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
