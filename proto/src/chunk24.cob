*> Level Chunk With Light body for a dimension of any number of sections (docs/protocol/06-chunk-
*> format.md §2 to §7), additive to the 001 functions of chunk.cob. The packet id (0x2E) is the
*> caller's. One chunk is passed as flat tables, section 0 (the lowest) first:
*>   states: sections x 4096 global block state ids, index section * 4096 + y * 256 + z * 16 + x + 1
*>   biomes: sections x 64 global biome ids, index section * 64 + y * 16 + z * 4 + x + 1
*>   counts: per section its non-empty block count and its fluid count, entries 2 * section + 1, + 2
*>   heightmaps: 6 x 256 values (HeightmapType ordinal t, column x + 16 * z, index t * 256 + column + 1),
*>     a mask of the types present (bit t) and the bits per entry ceillog2(height + 1) (06 §3.1)
*>   block entities: 5 BINARY-LONG per entry (local x 0 to 15, absolute y, local z 0 to 15, type id,
*>     data byte length) and the data bytes of all entries back to back; length 0 is an absent tag
*>   light: sections + 2 indices, as LIGHT-ENCODE and LIGHT-DECODE take them (chunk.cob)
*> Each section's containers are built from the ids: one distinct value is single value, up to 256
*> (blocks, bits byte at least 4) or 8 (biomes) distinct values are indirect in order of first
*> occurrence, more are direct at the global bits. A writer appends nothing and sets PB-ERROR for a
*> value it cannot encode; a reader that fails sets PB-ERROR and leaves PB-POS where it was.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-CHUNK-24.
*> USING PB-BUFFER, chunk x, chunk z, section count (1 to 64), heightmap bits (1 to 31), heightmap
*> mask (0 to 63), heightmap values, counts, states, biomes, block global bits, biome global bits,
*> block entity count, block entity heads, block entity data, sky light states, sky light arrays,
*> block light states, block light arrays (all BINARY-LONG unless a table; chunk.cob for light).
*> Counts outside 0 to 4096, a heightmap value outside its bits, a block entity with a local
*> coordinate outside 0 to 15, a y outside the Short range, a negative type or length, or data that is
*> not one complete compound, and anything the palette containers reject, are errors.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-START               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-POW2                BINARY-LONG.
 01 WS-LARGEST             BINARY-LONG.
 01 WS-HEADS               BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-LIGHT-COUNT         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-BLOCKS              BINARY-LONG VALUE 4096.
 01 WS-BIOMES              BINARY-LONG VALUE 64.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-DATA-OFFSET         BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG VALUE 2097152.
 01 WS-COLUMN-TABLE.
    05 WS-COLUMN           BINARY-LONG OCCURS 256 TIMES.
 01 B-MEM                  PIC X(1073741824) BASED.
 01 B-DATA                 PIC X(1073741824) BASED.
 01 B-HM-AREA BASED.
    05 B-HM                BINARY-LONG OCCURS 1536 TIMES.
 01 B-COUNT-AREA BASED.
    05 B-COUNT             BINARY-LONG OCCURS 128 TIMES.
 01 B-HEAD-AREA BASED.
    05 B-HEAD              BINARY-LONG OCCURS 5242880 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SECTIONS             BINARY-LONG.
 01 L-HM-BITS              BINARY-LONG.
 01 L-HM-MASK              BINARY-LONG.
 01 L-HM-VALUES            PIC X.
 01 L-COUNTS               PIC X.
 01 L-STATES               PIC X.
 01 L-BIOMES               PIC X.
 01 L-BLOCK-GBITS          BINARY-LONG.
 01 L-BIOME-GBITS          BINARY-LONG.
 01 L-BE-COUNT             BINARY-LONG.
 01 L-BE-HEADS             PIC X.
 01 L-BE-DATA              PIC X.
 01 L-SKY-STATES           PIC X.
 01 L-SKY-ARRAYS           PIC X.
 01 L-BLK-STATES           PIC X.
 01 L-BLK-ARRAYS           PIC X.
 PROCEDURE DIVISION USING PB-BUFFER L-X L-Z L-SECTIONS L-HM-BITS L-HM-MASK L-HM-VALUES
         L-COUNTS L-STATES L-BIOMES L-BLOCK-GBITS L-BIOME-GBITS L-BE-COUNT L-BE-HEADS L-BE-DATA
         L-SKY-STATES L-SKY-ARRAYS L-BLK-STATES L-BLK-ARRAYS.
     MOVE PB-LENGTH TO WS-START
     SET ADDRESS OF B-HM-AREA TO ADDRESS OF L-HM-VALUES
     SET ADDRESS OF B-COUNT-AREA TO ADDRESS OF L-COUNTS
     SET ADDRESS OF B-HEAD-AREA TO ADDRESS OF L-BE-HEADS
     SET ADDRESS OF B-DATA TO ADDRESS OF L-BE-DATA
*>   Everything the packet needs is checked before the first byte is written.
     MOVE 1 TO WS-OK
     IF L-SECTIONS < 1 OR L-SECTIONS > 64 OR L-HM-BITS < 1 OR L-HM-BITS > 31
             OR L-HM-MASK < 0 OR L-HM-MASK > 63 OR L-BE-COUNT < 0
         MOVE 0 TO WS-OK
     END-IF
     IF WS-OK = 1
         COMPUTE WS-LARGEST = 2 ** L-HM-BITS - 1
         MOVE 1 TO WS-POW2
         PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 5
             COMPUTE WS-Q = L-HM-MASK / WS-POW2
             COMPUTE WS-BIT = FUNCTION MOD(WS-Q, 2)
             IF WS-BIT = 1
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
                     COMPUTE WS-S = WS-T * 256 + WS-I
                     IF B-HM(WS-S) < 0 OR B-HM(WS-S) > WS-LARGEST
                         MOVE 0 TO WS-OK
                     END-IF
                 END-PERFORM
             END-IF
             MULTIPLY 2 BY WS-POW2
         END-PERFORM
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > L-SECTIONS * 2
             IF B-COUNT(WS-S) < 0 OR B-COUNT(WS-S) > 4096
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= L-BE-COUNT
             COMPUTE WS-I = WS-S * 5
             IF B-HEAD(WS-I + 1) < 0 OR B-HEAD(WS-I + 1) > 15
                     OR B-HEAD(WS-I + 2) < -32768 OR B-HEAD(WS-I + 2) > 32767
                     OR B-HEAD(WS-I + 3) < 0 OR B-HEAD(WS-I + 3) > 15
                     OR B-HEAD(WS-I + 4) < 0 OR B-HEAD(WS-I + 5) < 0
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
     END-IF
     IF WS-OK = 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-INT" USING PB-BUFFER L-X
     CALL "PB-PUT-INT" USING PB-BUFFER L-Z
*>   Heightmaps: the types of the mask in ascending order, each a prefixed array of Longs.
     MOVE 0 TO WS-HEADS
     MOVE 1 TO WS-POW2
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 5
         COMPUTE WS-Q = L-HM-MASK / WS-POW2
         COMPUTE WS-BIT = FUNCTION MOD(WS-Q, 2)
         ADD WS-BIT TO WS-HEADS
         MULTIPLY 2 BY WS-POW2
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HEADS
     COMPUTE WS-PER-LONG = 64 / L-HM-BITS
     COMPUTE WS-LONGS = (256 + WS-PER-LONG - 1) / WS-PER-LONG
     MOVE 1 TO WS-POW2
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 5
         COMPUTE WS-Q = L-HM-MASK / WS-POW2
         COMPUTE WS-BIT = FUNCTION MOD(WS-Q, 2)
         IF WS-BIT = 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-T
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-LONGS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
                 COMPUTE WS-S = WS-T * 256 + WS-I
                 MOVE B-HM(WS-S) TO WS-COLUMN(WS-I)
             END-PERFORM
             MOVE 256 TO WS-LENGTH
             CALL "PB-PUT-PACKED-LONGS" USING PB-BUFFER WS-COLUMN-TABLE WS-LENGTH L-HM-BITS
         END-IF
         MULTIPLY 2 BY WS-POW2
     END-PERFORM
*>   Sections into a scratch buffer, then the byte array with its length.
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= L-SECTIONS OR WK-ERROR = 1
         COMPUTE WS-I = WS-S * 2 + 1
         CALL "PB-PUT-SHORT" USING WK-BUFFER B-COUNT(WS-I)
         COMPUTE WS-I = WS-S * 2 + 2
         CALL "PB-PUT-SHORT" USING WK-BUFFER B-COUNT(WS-I)
         COMPUTE WS-OFFSET = WS-S * 4096
         CALL "CHUNK-BUILD-CONTAINER" USING WK-PALETTE-CONTAINER L-STATES WS-OFFSET WS-BLOCKS
             L-BLOCK-GBITS
         CALL "PB-PUT-PALETTE-CONTAINER" USING WK-BUFFER WK-PALETTE-CONTAINER L-BLOCK-GBITS
         COMPUTE WS-OFFSET = WS-S * 64
         CALL "CHUNK-BUILD-CONTAINER" USING WK-PALETTE-CONTAINER L-BIOMES WS-OFFSET WS-BIOMES
             L-BIOME-GBITS
         CALL "PB-PUT-PALETTE-CONTAINER" USING WK-BUFFER WK-PALETTE-CONTAINER L-BIOME-GBITS
     END-PERFORM
     IF WK-ERROR = 1 OR WK-LENGTH > WS-LIMIT
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WK-LENGTH
         SET ADDRESS OF B-MEM TO WK-ADDR
         CALL "PB-APPEND-BYTES" USING PB-BUFFER B-MEM WK-LENGTH
     END-IF
     CALL "PB-FREE" USING WK-BUFFER
     IF PB-ERROR = 1
         MOVE WS-START TO PB-LENGTH
         GOBACK
     END-IF
*>   Block entities: packed local x and z, absolute y, type, the optional tag (absent is End).
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-BE-COUNT
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     MOVE 0 TO WS-DATA-OFFSET
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= L-BE-COUNT OR PB-ERROR = 1
         COMPUTE WS-I = WS-S * 5
         COMPUTE WS-BYTE = B-HEAD(WS-I + 1) * 16 + B-HEAD(WS-I + 3)
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
         CALL "PB-PUT-SHORT" USING PB-BUFFER B-HEAD(WS-I + 2)
         CALL "PB-PUT-VARINT" USING PB-BUFFER B-HEAD(WS-I + 4)
         MOVE B-HEAD(WS-I + 5) TO WS-LENGTH
         IF WS-LENGTH = 0
             MOVE 0 TO WS-BYTE
             CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
         ELSE
             CALL "PB-RESET" USING WK-BUFFER
             CALL "PB-APPEND-BYTES" USING WK-BUFFER B-DATA(WS-DATA-OFFSET + 1:WS-LENGTH)
                 WS-LENGTH
             MOVE 0 TO WS-TAG-LENGTH
             CALL "REGISTRY-NBT-TAG" USING WK-BUFFER WS-TAG-LENGTH
             SET ADDRESS OF B-MEM TO WK-ADDR
             IF WK-ERROR = 1 OR WS-TAG-LENGTH NOT = WS-LENGTH OR B-MEM(1:1) NOT = X"0A"
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-APPEND-BYTES" USING PB-BUFFER B-MEM WS-LENGTH
             END-IF
             ADD WS-LENGTH TO WS-DATA-OFFSET
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING WK-BUFFER
     IF PB-ERROR = 1
         MOVE WS-START TO PB-LENGTH
         GOBACK
     END-IF
     COMPUTE WS-LIGHT-COUNT = L-SECTIONS + 2
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-LIGHT-COUNT L-SKY-STATES L-SKY-ARRAYS
         L-BLK-STATES L-BLK-ARRAYS
     GOBACK.
 END PROGRAM PB-PUT-CHUNK-24.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-CHUNK-24.
*> USING PB-BUFFER, chunk x out, chunk z out, section count (1 to 64), heightmap bits (1 to 31),
*> heightmap mask out, heightmap values out (6 x 256, types not present zero), counts out, states
*> out, biomes out, block global bits, biome global bits, block entity capacity (entries), block
*> entity data capacity (bytes), block entity count out, block entity heads out, block entity data
*> out, sky light states out, sky light arrays out, block light states out, block light arrays out
*> (layouts as PB-PUT-CHUNK-24). A heightmap type above 5 or twice, a Long count other than the
*> bits imply, a section buffer above 2 MiB or past the packet or not exactly filled by the
*> sections, a count outside 0 to 4096, a bad palette container, block entities above a capacity,
*> an entity tag that is neither End nor a compound, or bad light: PB-ERROR, PB-POS back at the start.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-POW2                BINARY-LONG.
 01 WS-HEADS               BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-DECLARED            BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-LIGHT-COUNT         BINARY-LONG.
 01 WS-BLOCKS              BINARY-LONG VALUE 4096.
 01 WS-BIOMES              BINARY-LONG VALUE 64.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-DATA-OFFSET         BINARY-LONG.
 01 WS-TAG-START           BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-LIMIT               BINARY-LONG VALUE 2097152.
 01 WS-COLUMN-TABLE.
    05 WS-COLUMN           BINARY-LONG OCCURS 256 TIMES.
 01 B-DATA                 PIC X(1073741824) BASED.
 01 B-HM-AREA BASED.
    05 B-HM                BINARY-LONG OCCURS 1536 TIMES.
 01 B-COUNT-AREA BASED.
    05 B-COUNT             BINARY-LONG OCCURS 128 TIMES.
 01 B-HEAD-AREA BASED.
    05 B-HEAD              BINARY-LONG OCCURS 5242880 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SECTIONS             BINARY-LONG.
 01 L-HM-BITS              BINARY-LONG.
 01 L-HM-MASK              BINARY-LONG.
 01 L-HM-VALUES            PIC X.
 01 L-COUNTS               PIC X.
 01 L-STATES               PIC X.
 01 L-BIOMES               PIC X.
 01 L-BLOCK-GBITS          BINARY-LONG.
 01 L-BIOME-GBITS          BINARY-LONG.
 01 L-BE-MAX               BINARY-LONG.
 01 L-BE-DATA-MAX          BINARY-LONG.
 01 L-BE-COUNT             BINARY-LONG.
 01 L-BE-HEADS             PIC X.
 01 L-BE-DATA              PIC X.
 01 L-SKY-STATES           PIC X.
 01 L-SKY-ARRAYS           PIC X.
 01 L-BLK-STATES           PIC X.
 01 L-BLK-ARRAYS           PIC X.
 PROCEDURE DIVISION USING PB-BUFFER L-X L-Z L-SECTIONS L-HM-BITS L-HM-MASK L-HM-VALUES
         L-COUNTS L-STATES L-BIOMES L-BLOCK-GBITS L-BIOME-GBITS L-BE-MAX L-BE-DATA-MAX
         L-BE-COUNT L-BE-HEADS L-BE-DATA L-SKY-STATES L-SKY-ARRAYS L-BLK-STATES L-BLK-ARRAYS.
     MOVE PB-POS TO WS-START
     SET ADDRESS OF B-HM-AREA TO ADDRESS OF L-HM-VALUES
     SET ADDRESS OF B-COUNT-AREA TO ADDRESS OF L-COUNTS
     SET ADDRESS OF B-HEAD-AREA TO ADDRESS OF L-BE-HEADS
     SET ADDRESS OF B-DATA TO ADDRESS OF L-BE-DATA
     MOVE 0 TO L-HM-MASK L-BE-COUNT
     IF L-SECTIONS < 1 OR L-SECTIONS > 64 OR L-HM-BITS < 1 OR L-HM-BITS > 31
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE 0 TO B-HM(WS-I)
     END-PERFORM
     CALL "PB-GET-INT" USING PB-BUFFER L-X
     CALL "PB-GET-INT" USING PB-BUFFER L-Z
*>   Heightmaps.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-HEADS
     IF WS-HEADS < 0 OR WS-HEADS > 6
         MOVE 1 TO PB-ERROR
     END-IF
     COMPUTE WS-PER-LONG = 64 / L-HM-BITS
     COMPUTE WS-LONGS = (256 + WS-PER-LONG - 1) / WS-PER-LONG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-HEADS OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-T
         IF WS-T < 0 OR WS-T > 5
             MOVE 1 TO PB-ERROR
         END-IF
         IF PB-ERROR = 0
             MOVE 1 TO WS-POW2
             PERFORM WS-T TIMES
                 MULTIPLY 2 BY WS-POW2
             END-PERFORM
             COMPUTE WS-Q = L-HM-MASK / WS-POW2
             COMPUTE WS-BIT = FUNCTION MOD(WS-Q, 2)
             IF WS-BIT = 1
                 MOVE 1 TO PB-ERROR
             END-IF
         END-IF
         IF PB-ERROR = 0
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-LENGTH
             IF WS-LENGTH NOT = WS-LONGS
                 MOVE 1 TO PB-ERROR
             END-IF
         END-IF
         IF PB-ERROR = 0
             MOVE 256 TO WS-LENGTH
             CALL "PB-GET-PACKED-LONGS" USING PB-BUFFER WS-COLUMN-TABLE WS-LENGTH L-HM-BITS
             ADD WS-POW2 TO L-HM-MASK
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 256
                 COMPUTE WS-Q = WS-T * 256 + WS-S
                 MOVE WS-COLUMN(WS-S) TO B-HM(WS-Q)
             END-PERFORM
         END-IF
     END-PERFORM
*>   Sections: the byte array's length, then exactly that many bytes of sections.
     IF PB-ERROR = 0
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-DECLARED
         IF WS-DECLARED < 0 OR WS-DECLARED > WS-LIMIT OR WS-DECLARED > PB-LENGTH - PB-POS
             MOVE 1 TO PB-ERROR
         END-IF
     END-IF
     IF PB-ERROR = 0
         COMPUTE WS-END = PB-POS + WS-DECLARED
     END-IF
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= L-SECTIONS OR PB-ERROR = 1
         COMPUTE WS-I = WS-S * 2 + 1
         CALL "PB-GET-SHORT" USING PB-BUFFER B-COUNT(WS-I)
         COMPUTE WS-I = WS-S * 2 + 2
         CALL "PB-GET-SHORT" USING PB-BUFFER B-COUNT(WS-I)
         COMPUTE WS-I = WS-S * 2 + 1
         IF B-COUNT(WS-I) < 0 OR B-COUNT(WS-I) > 4096 OR B-COUNT(WS-I + 1) < 0
                 OR B-COUNT(WS-I + 1) > 4096
             MOVE 1 TO PB-ERROR
         END-IF
         MOVE WS-BLOCKS TO WK-PC-ENTRIES
         CALL "PB-GET-PALETTE-CONTAINER" USING PB-BUFFER WK-PALETTE-CONTAINER L-BLOCK-GBITS
         COMPUTE WS-OFFSET = WS-S * 4096
         CALL "CHUNK-RESOLVE-CONTAINER" USING WK-PALETTE-CONTAINER L-STATES WS-OFFSET
         MOVE WS-BIOMES TO WK-PC-ENTRIES
         CALL "PB-GET-PALETTE-CONTAINER" USING PB-BUFFER WK-PALETTE-CONTAINER L-BIOME-GBITS
         COMPUTE WS-OFFSET = WS-S * 64
         CALL "CHUNK-RESOLVE-CONTAINER" USING WK-PALETTE-CONTAINER L-BIOMES WS-OFFSET
     END-PERFORM
     IF PB-ERROR = 0 AND PB-POS NOT = WS-END
         MOVE 1 TO PB-ERROR
     END-IF
*>   Block entities.
     IF PB-ERROR = 0
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-HEADS
         IF WS-HEADS < 0 OR WS-HEADS > L-BE-MAX
             MOVE 1 TO PB-ERROR
         END-IF
     END-IF
     MOVE 0 TO WS-DATA-OFFSET
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-HEADS OR PB-ERROR = 1
         CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
         CALL "PB-GET-SHORT" USING PB-BUFFER WS-Y
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-TYPE
         DIVIDE WS-BYTE BY 16 GIVING WS-X REMAINDER WS-Z
         IF WS-TYPE < 0
             MOVE 1 TO PB-ERROR
         END-IF
         MOVE PB-POS TO WS-TAG-START
         IF PB-ERROR = 0
             CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-LENGTH
         END-IF
         EVALUATE TRUE
             WHEN PB-ERROR = 1
                 CONTINUE
             WHEN WS-LENGTH = 0
                 MOVE 0 TO WS-LENGTH
             WHEN WS-LENGTH = 10
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-LENGTH
                 COMPUTE WS-LENGTH = PB-POS - WS-TAG-START
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
         IF PB-ERROR = 0 AND WS-DATA-OFFSET + WS-LENGTH > L-BE-DATA-MAX
             MOVE 1 TO PB-ERROR
         END-IF
         IF PB-ERROR = 0
             COMPUTE WS-I = WS-S * 5
             MOVE WS-X TO B-HEAD(WS-I + 1)
             MOVE WS-Y TO B-HEAD(WS-I + 2)
             MOVE WS-Z TO B-HEAD(WS-I + 3)
             MOVE WS-TYPE TO B-HEAD(WS-I + 4)
             MOVE WS-LENGTH TO B-HEAD(WS-I + 5)
             IF WS-LENGTH > 0
                 MOVE WS-TAG-START TO PB-POS
                 CALL "PB-GET-BYTES" USING PB-BUFFER B-DATA(WS-DATA-OFFSET + 1:WS-LENGTH)
                     WS-LENGTH
                 ADD WS-LENGTH TO WS-DATA-OFFSET
             END-IF
         END-IF
     END-PERFORM
     IF PB-ERROR = 0
         MOVE WS-HEADS TO L-BE-COUNT
         COMPUTE WS-LIGHT-COUNT = L-SECTIONS + 2
         CALL "LIGHT-DECODE" USING PB-BUFFER WS-LIGHT-COUNT L-SKY-STATES L-SKY-ARRAYS
             L-BLK-STATES L-BLK-ARRAYS
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-HM-MASK L-BE-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-GET-CHUNK-24.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-BUILD-CONTAINER.
*> USING PB-PALETTE-CONTAINER out, ids (a table of BINARY-LONG), offset (BINARY-LONG, entries to skip),
*> entries (4096 or 64), global bits (BINARY-LONG): the container for the entries after the offset.
*> Up to 256 (blocks) or 8 (biomes) distinct ids are indirect in order of first occurrence, with a bits
*> byte of ceillog2 (at least 4 for blocks, 06 §5.3), one is single value, more are direct. A negative
*> id is left for PB-PUT-PALETTE-CONTAINER to reject.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-OVERFLOW            BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 B-IDS-AREA BASED.
    05 B-ID                BINARY-LONG OCCURS 262144 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-IDS                  PIC X.
 01 L-OFFSET               BINARY-LONG.
 01 L-ENTRIES              BINARY-LONG.
 01 L-GLOBAL-BITS          BINARY-LONG.
 PROCEDURE DIVISION USING PB-PALETTE-CONTAINER L-IDS L-OFFSET L-ENTRIES L-GLOBAL-BITS.
     SET ADDRESS OF B-IDS-AREA TO ADDRESS OF L-IDS
     MOVE L-ENTRIES TO PB-PC-ENTRIES
     MOVE 0 TO PB-PC-PALETTE-COUNT WS-OVERFLOW
     MOVE 1 TO WS-LAST
     MOVE 8 TO WS-LIMIT
     IF L-ENTRIES = 4096
         MOVE 256 TO WS-LIMIT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-ENTRIES OR WS-OVERFLOW = 1
         COMPUTE WS-J = L-OFFSET + WS-I
         MOVE B-ID(WS-J) TO WS-VALUE
         IF PB-PC-PALETTE-COUNT > 0 AND WS-VALUE = PB-PC-PALETTE(WS-LAST)
             CONTINUE
         ELSE
             PERFORM VARYING WS-J FROM 1 BY 1
                     UNTIL WS-J > PB-PC-PALETTE-COUNT OR PB-PC-PALETTE(WS-J) = WS-VALUE
                 CONTINUE
             END-PERFORM
             IF WS-J > PB-PC-PALETTE-COUNT
                 IF PB-PC-PALETTE-COUNT = WS-LIMIT
                     MOVE 1 TO WS-OVERFLOW
                 ELSE
                     ADD 1 TO PB-PC-PALETTE-COUNT
                     MOVE WS-VALUE TO PB-PC-PALETTE(WS-J)
                 END-IF
             END-IF
             MOVE WS-J TO WS-LAST
         END-IF
         COMPUTE PB-PC-VALUE(WS-I) = WS-LAST - 1
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-OVERFLOW = 1
             MOVE PB-PC-DIRECT TO PB-PC-KIND
             MOVE L-GLOBAL-BITS TO PB-PC-BITS
             MOVE 0 TO PB-PC-PALETTE-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-ENTRIES
                 COMPUTE WS-J = L-OFFSET + WS-I
                 MOVE B-ID(WS-J) TO PB-PC-VALUE(WS-I)
             END-PERFORM
         WHEN PB-PC-PALETTE-COUNT = 1
             MOVE PB-PC-SINGLE TO PB-PC-KIND
             MOVE 0 TO PB-PC-BITS
         WHEN OTHER
             MOVE PB-PC-INDIRECT TO PB-PC-KIND
             MOVE 0 TO WS-BITS
             PERFORM UNTIL 2 ** WS-BITS >= PB-PC-PALETTE-COUNT
                 ADD 1 TO WS-BITS
             END-PERFORM
             IF L-ENTRIES = 4096 AND WS-BITS < 4
                 MOVE 4 TO WS-BITS
             END-IF
             MOVE WS-BITS TO PB-PC-BITS
     END-EVALUATE
     GOBACK.
 END PROGRAM CHUNK-BUILD-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-RESOLVE-CONTAINER.
*> USING PB-PALETTE-CONTAINER (as PB-GET-PALETTE-CONTAINER filled it), ids out (a table of
*> BINARY-LONG), offset (BINARY-LONG, entries to skip): the global id of each entry. A cleared record
*> from a failed read gives zeros.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 B-IDS-AREA BASED.
    05 B-ID                BINARY-LONG OCCURS 262144 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-IDS                  PIC X.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING PB-PALETTE-CONTAINER L-IDS L-OFFSET.
     SET ADDRESS OF B-IDS-AREA TO ADDRESS OF L-IDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-PC-ENTRIES
         COMPUTE WS-J = L-OFFSET + WS-I
         EVALUATE PB-PC-KIND
             WHEN PB-PC-SINGLE
                 MOVE PB-PC-PALETTE(1) TO B-ID(WS-J)
             WHEN PB-PC-INDIRECT
                 MOVE PB-PC-PALETTE(PB-PC-VALUE(WS-I) + 1) TO B-ID(WS-J)
             WHEN OTHER
                 MOVE PB-PC-VALUE(WS-I) TO B-ID(WS-J)
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-RESOLVE-CONTAINER.
