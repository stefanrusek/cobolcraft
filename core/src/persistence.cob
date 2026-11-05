*> The world folder (docs/protocol/07-nbt-and-anvil.md §9; contracts/world-folder.md; FR-004, FR-014):
*> level.dat, access.dat, players/<offline-uuid>.dat (gzip NBT files through proto NBT-FILE-WRITE and
*> NBT-FILE-READ, 07 §5.1) and, per dimension, dimensions/<namespace>/<path>/region and entities
*> (Anvil region files, core/src/region.cob). Every root carries DataVersion 5023 (07 §9.1).
*>
*> Programs that build NBT name each tag through WN (the name) and WL (its byte length); list
*> elements use the name length -1 (contracts/proto-api.md §5). Programs that read walk compounds
*> entry by entry (NBT-READ-COMPOUND-NEXT), act on the keys they know and skip the others
*> (NBT-READ-SKIP), so key order never matters (07 §1.2). A malformed stream leaves PB-ERROR set.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-NBT-WRITE.
*> USING cache row (BINARY-LONG), PB-BUFFER (appended to): the chunk as a named-root compound (07 §7
*> with §9.4): DataVersion, xPos, yPos (min section Y), zPos, LastUpdate (the world time),
*> InhabitedTime 0, Status minecraft:full; sections (one per 16 block layers: Y, block_states,
*> biomes; no light arrays, so no isLightOn either: light is recomputed on load); empty
*> block_entities, block_ticks and fluid_ticks; PostProcessing with one empty list per section;
*> Heightmaps WORLD_SURFACE, MOTION_BLOCKING and MOTION_BLOCKING_NO_LEAVES (CHUNK-HEIGHTMAP); and
*> structures {starts: {}, References: {}} (07 Open question 9).
*> Block-state palettes (07 §7.2, §7.3) list the distinct states in first-occurrence order: a
*> block's default state as its key (a String), any other state as {id, properties}; a palette that
*> has both is a list of compounds in which each key is wrapped as {"": key} (07 §1.1). The packed
*> data (SimpleBitStorage, at least 4 bits for block states) is written when the palette has more
*> than one entry. Biome palettes hold the keys of the generator's biomes (WORLDGEN-DIM-BIOMES).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BLOCKS.
 COPY REGISTRY.
 COPY CHUNKMEM.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-MIN-SECTION         BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OTHERS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PER                 BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-PAL-INDEXES.
    05 WS-PAL-INDEX        BINARY-LONG OCCURS 256 TIMES.
 01 WS-PALETTE.
    05 WS-PAL              BINARY-LONG OCCURS 4096 TIMES.
 01 WS-INDEXES.
    05 WS-INDEX            BINARY-LONG OCCURS 4096 TIMES.
 01 WS-MULS.
    05 WS-MUL              BINARY-DOUBLE UNSIGNED OCCURS 64 TIMES.
 01 WS-DATA-U.
    05 WS-DU               BINARY-DOUBLE UNSIGNED OCCURS 1024 TIMES.
 01 WS-DATA-S REDEFINES WS-DATA-U.
    05 WS-DS               BINARY-DOUBLE OCCURS 1024 TIMES.
 01 WS-HM-LONGS            BINARY-LONG.
 01 WS-HEIGHTMAP-U.
    05 WS-HMU              BINARY-DOUBLE UNSIGNED OCCURS 256 TIMES.
 01 WS-HEIGHTMAP-S REDEFINES WS-HEIGHTMAP-U.
    05 WS-HMS              BINARY-DOUBLE OCCURS 256 TIMES.
 01 WS-BIOME-COLUMNS.
    05 WS-BIOME-COLUMN     BINARY-LONG OCCURS 16 TIMES.
 01 WS-PROPS               PIC X(24).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PNAME               PIC X(24).
 01 WS-PNAME-LENGTH        BINARY-LONG.
 01 WS-PVALUE              PIC X(24).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE CK-DIM(L-ROW) TO WS-DIM
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-SECTIONS = DM-HEIGHT(WS-DIM) / 16
     COMPUTE WS-MIN-SECTION = DM-MIN-Y(WS-DIM) / 16
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "xPos" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CK-X(L-ROW)
     MOVE "yPos" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-MIN-SECTION
     MOVE "zPos" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CK-Z(L-ROW)
     MOVE "LastUpdate" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-TIME
     MOVE "InhabitedTime" TO WN MOVE 13 TO WL
     MOVE 0 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "Status" TO WN MOVE 6 TO WL
     MOVE "minecraft:full" TO WS-TEXT
     MOVE 14 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     MOVE "sections" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-SECTIONS
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM CK-X(L-ROW) CK-Z(L-ROW) WS-BIOME-COLUMNS
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
         MOVE "Y" TO WN MOVE 1 TO WL
         COMPUTE WS-INT = WS-S + WS-MIN-SECTION
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
*>       Block states: the palette in first-occurrence order and each cell's palette index.
         MOVE "block_states" TO WN MOVE 12 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         INITIALIZE WS-PAL-INDEXES
         MOVE 0 TO WS-N WS-OTHERS
         COMPUTE WS-BASE = WS-S * 4096
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE CM-STATE(WS-BASE + WS-I) TO WS-STATE
             IF WS-PAL-INDEX(WS-STATE + 1) = 0
                 ADD 1 TO WS-N
                 MOVE WS-N TO WS-PAL-INDEX(WS-STATE + 1)
                 MOVE WS-STATE TO WS-PAL(WS-N)
                 IF BL-DEFAULT-STATE(SB-BLOCK(WS-STATE + 1) + 1) NOT = WS-STATE
                     ADD 1 TO WS-OTHERS
                 END-IF
             END-IF
             COMPUTE WS-INDEX(WS-I) = WS-PAL-INDEX(WS-STATE + 1) - 1
         END-PERFORM
         MOVE "palette" TO WN MOVE 7 TO WL
         MOVE WS-T-STRING TO WS-TYPE
         IF WS-OTHERS > 0
             MOVE WS-T-COMPOUND TO WS-TYPE
         END-IF
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-TYPE WS-N
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
             MOVE WS-PAL(WS-K) TO WS-STATE
             MOVE SB-BLOCK(WS-STATE + 1) TO WS-BLOCK
             EVALUATE TRUE
                 WHEN WS-OTHERS = 0
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT BL-KEY(WS-BLOCK + 1)
                         BL-KEY-LENGTH(WS-BLOCK + 1)
                 WHEN BL-DEFAULT-STATE(WS-BLOCK + 1) = WS-STATE
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                     MOVE 0 TO WL
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BL-KEY(WS-BLOCK + 1)
                         BL-KEY-LENGTH(WS-BLOCK + 1)
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 WHEN OTHER
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                     MOVE "id" TO WN MOVE 2 TO WL
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BL-KEY(WS-BLOCK + 1)
                         BL-KEY-LENGTH(WS-BLOCK + 1)
                     MOVE "properties" TO WN MOVE 10 TO WL
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
                     MOVE SB-PROPS(WS-STATE + 1) TO WS-PROPS
                     MOVE 1 TO WS-PTR
                     PERFORM UNTIL WS-PTR > 24
                         MOVE SPACES TO WS-PNAME WS-PVALUE
                         MOVE 0 TO WS-PNAME-LENGTH WS-PVALUE-LENGTH
                         UNSTRING WS-PROPS DELIMITED BY "=" OR "," OR SPACE
                             INTO WS-PNAME COUNT WS-PNAME-LENGTH
                                  WS-PVALUE COUNT WS-PVALUE-LENGTH
                             WITH POINTER WS-PTR
                         END-UNSTRING
                         IF WS-PNAME-LENGTH = 0
                             EXIT PERFORM
                         END-IF
                         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-PNAME WS-PNAME-LENGTH
                             WS-PVALUE WS-PVALUE-LENGTH
                     END-PERFORM
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-EVALUATE
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
         MOVE 4096 TO WS-ENTRIES
         MOVE 4 TO WS-BITS
         MOVE 16 TO WS-RANGE
         IF WS-N > 1
             PERFORM UNTIL WS-RANGE >= WS-N
                 ADD 1 TO WS-BITS
                 COMPUTE WS-RANGE = WS-RANGE * 2
             END-PERFORM
             COMPUTE WS-PER = 64 / WS-BITS
             COMPUTE WS-LONGS = (WS-ENTRIES + WS-PER - 1) / WS-PER
             MOVE 1 TO WS-MUL(1)
             PERFORM VARYING WS-SLOT FROM 2 BY 1 UNTIL WS-SLOT > WS-PER
                 COMPUTE WS-MUL(WS-SLOT) = WS-MUL(WS-SLOT - 1) * WS-RANGE
             END-PERFORM
             INITIALIZE WS-DATA-U
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-ENTRIES
                 COMPUTE WS-K = WS-I / WS-PER
                 COMPUTE WS-SLOT = WS-I - WS-K * WS-PER
                 COMPUTE WS-DU(WS-K + 1) = WS-DU(WS-K + 1)
                     + WS-INDEX(WS-I + 1) * WS-MUL(WS-SLOT + 1)
             END-PERFORM
             MOVE "data" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WN WL WS-LONGS WS-DATA-S
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>       Biomes: index y * 16 + z * 4 + x; every Y of a column has the column's biome.
         MOVE "biomes" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         INITIALIZE WS-PAL-INDEXES
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE WS-BIOME-COLUMN(FUNCTION MOD(WS-I - 1, 16) + 1) TO WS-STATE
             IF WS-PAL-INDEX(WS-STATE + 1) = 0
                 ADD 1 TO WS-N
                 MOVE WS-N TO WS-PAL-INDEX(WS-STATE + 1)
                 MOVE WS-STATE TO WS-PAL(WS-N)
             END-IF
             COMPUTE WS-INDEX(WS-I) = WS-PAL-INDEX(WS-STATE + 1) - 1
         END-PERFORM
         MOVE "palette" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-N
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT RB-KEY(WS-PAL(WS-K) + 1)
                 RB-KEY-LENGTH(WS-PAL(WS-K) + 1)
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
*>       At most RB-COUNT (3) biomes: 1 bit for 2 entries, 2 bits for 3 (07 §7.2 biome column).
         MOVE 64 TO WS-ENTRIES
         IF WS-N > 1
             COMPUTE WS-BITS = FUNCTION MIN(2, WS-N - 1)
             COMPUTE WS-RANGE = 2 ** WS-BITS
             COMPUTE WS-PER = 64 / WS-BITS
             COMPUTE WS-LONGS = (WS-ENTRIES + WS-PER - 1) / WS-PER
             MOVE 1 TO WS-MUL(1)
             PERFORM VARYING WS-SLOT FROM 2 BY 1 UNTIL WS-SLOT > WS-PER
                 COMPUTE WS-MUL(WS-SLOT) = WS-MUL(WS-SLOT - 1) * WS-RANGE
             END-PERFORM
             INITIALIZE WS-DATA-U
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-ENTRIES
                 COMPUTE WS-K = WS-I / WS-PER
                 COMPUTE WS-SLOT = WS-I - WS-K * WS-PER
                 COMPUTE WS-DU(WS-K + 1) = WS-DU(WS-K + 1)
                     + WS-INDEX(WS-I + 1) * WS-MUL(WS-SLOT + 1)
             END-PERFORM
             MOVE "data" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WN WL WS-LONGS WS-DATA-S
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     MOVE "block_entities" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE WS-ZERO
     MOVE "block_ticks" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE WS-ZERO
     MOVE "fluid_ticks" TO WN
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE WS-ZERO
     MOVE "PostProcessing" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-LIST WS-SECTIONS
     PERFORM WS-SECTIONS TIMES
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WS-ELEMENT WS-T-NONE WS-ZERO
     END-PERFORM
     MOVE "Heightmaps" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "CHUNK-HEIGHTMAP" USING L-ROW WS-HM-LONGS WS-HEIGHTMAP-U
     MOVE "WORLD_SURFACE" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WN WL WS-HM-LONGS WS-HEIGHTMAP-S
     MOVE "MOTION_BLOCKING" TO WN MOVE 15 TO WL
     CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WN WL WS-HM-LONGS WS-HEIGHTMAP-S
     MOVE "MOTION_BLOCKING_NO_LEAVES" TO WN MOVE 25 TO WL
     CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WN WL WS-HM-LONGS WS-HEIGHTMAP-S
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "References" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM CHUNK-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-NBT-READ.
*> USING cache row (BINARY-LONG; its memory allocated), PB-BUFFER (a named-root chunk compound at
*> PB-POS), outcome out (BINARY-LONG: 0 read, 1 malformed). Every cell starts as void; each section
*> inside the dimension's range is filled from its block-state palette and data (CHUNK-NBT-SECTION);
*> biomes are not read (the generator gives them again). The section light source counts are
*> recounted; the chunk is unchanged and not lit (light is computed on first use).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKS.
 COPY CHUNKMEM.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER L-OUTCOME.
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     MOVE LOW-VALUES TO CM-STATES
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "sections" AND WS-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "CHUNK-NBT-SECTION" USING L-ROW PB-BUFFER
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO CK-SOURCES(L-ROW, WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-CHUNK-CELLS
         IF SB-LIGHT(CM-STATE(WS-I) + 1) > 0
             ADD 1 TO CK-SOURCES(L-ROW, (WS-I - 1) / 4096 + 1)
         END-IF
     END-PERFORM
     MOVE 0 TO CK-CHANGED(L-ROW) CK-LIT(L-ROW)
     MOVE PB-ERROR TO L-OUTCOME
     GOBACK.
 END PROGRAM CHUNK-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-NBT-SECTION.
*> USING cache row, PB-BUFFER (a section compound payload at PB-POS, 07 §7.1): reads Y and
*> block_states (palette entries through CHUNK-NBT-BLOCK-STATE; data unpacked with the bits the
*> palette size gives, 07 §7.2) and fills that section's cells. A section outside the dimension's
*> block range is ignored; an index outside the palette reads as void.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CHUNKMEM.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PER                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-Q                   BINARY-DOUBLE UNSIGNED.
 01 WS-Q2                  BINARY-DOUBLE UNSIGNED.
 01 WS-VALUE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LONG-CAPACITY       BINARY-LONG VALUE 1024.
 01 WS-LONG-COUNT          BINARY-LONG.
 01 WS-PALETTE.
    05 WS-PAL              BINARY-LONG OCCURS 4096 TIMES.
 01 WS-MULS.
    05 WS-MUL              BINARY-DOUBLE UNSIGNED OCCURS 64 TIMES.
 01 WS-DATA-U.
    05 WS-DU               BINARY-DOUBLE UNSIGNED OCCURS 1024 TIMES.
 01 WS-DATA-S REDEFINES WS-DATA-U.
    05 WS-DS               BINARY-DOUBLE OCCURS 1024 TIMES.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAIRS               PIC X(64).
 01 WS-PAIR-COUNT          BINARY-LONG.
 01 WS-PNAME               PIC X(32).
 01 WS-PNAME-LENGTH        BINARY-LONG.
 01 WS-PVALUE              PIC X(32).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE -9999 TO WS-Y
     MOVE 0 TO WS-N WS-LONG-COUNT
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Y" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-Y
             WHEN WN = "block_states" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "palette" AND WS-INNER-TYPE = 9
                             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-N
                             MOVE FUNCTION MIN(WS-N, 4096) TO WS-N
                             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N OR PB-ERROR = 1
                                 MOVE SPACES TO WS-KEY WS-PAIRS
                                 MOVE 0 TO WS-KEY-LENGTH WS-PAIR-COUNT
                                 IF WS-ELEMENT-TYPE = 8
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-CAPACITY
                                         WS-KEY-LENGTH
                                 ELSE
                                     CALL "CHUNK-NBT-PALETTE-ENTRY" USING PB-BUFFER WS-ELEMENT-TYPE
                                         WS-KEY WS-KEY-LENGTH WS-PAIRS WS-PAIR-COUNT
                                 END-IF
                                 CALL "CHUNK-NBT-BLOCK-STATE" USING WS-KEY WS-PAIRS WS-PAIR-COUNT
                                     WS-PAL(WS-K)
                             END-PERFORM
                         WHEN WN = "data" AND WS-INNER-TYPE = 12
                             CALL "NBT-READ-LONG-ARRAY" USING PB-BUFFER WS-LONG-CAPACITY
                                 WS-LONG-COUNT WS-DATA-S
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-Y = WS-Y - DM-MIN-Y(CK-DIM(L-ROW)) / 16
     IF WS-Y < 0 OR WS-Y >= DM-HEIGHT(CK-DIM(L-ROW)) / 16 OR WS-N = 0 OR PB-ERROR = 1
         GOBACK
     END-IF
     COMPUTE WS-BASE = WS-Y * 4096
     IF WS-N = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE WS-PAL(1) TO CM-STATE(WS-BASE + WS-I)
         END-PERFORM
         GOBACK
     END-IF
     MOVE 4 TO WS-BITS
     MOVE 16 TO WS-RANGE
     PERFORM UNTIL WS-RANGE >= WS-N
         ADD 1 TO WS-BITS
         COMPUTE WS-RANGE = WS-RANGE * 2
     END-PERFORM
     COMPUTE WS-PER = 64 / WS-BITS
     MOVE 1 TO WS-MUL(1)
     PERFORM VARYING WS-SLOT FROM 2 BY 1 UNTIL WS-SLOT > WS-PER
         COMPUTE WS-MUL(WS-SLOT) = WS-MUL(WS-SLOT - 1) * WS-RANGE
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4095
         COMPUTE WS-K = WS-I / WS-PER
         COMPUTE WS-SLOT = WS-I - WS-K * WS-PER
         MOVE 0 TO WS-STATE
         IF WS-K < WS-LONG-COUNT
             COMPUTE WS-Q = WS-DU(WS-K + 1) / WS-MUL(WS-SLOT + 1)
             COMPUTE WS-Q2 = WS-Q / WS-RANGE
             COMPUTE WS-VALUE = WS-Q - WS-Q2 * WS-RANGE
             IF WS-VALUE < WS-N
                 MOVE WS-PAL(WS-VALUE + 1) TO WS-STATE
             END-IF
         END-IF
         MOVE WS-STATE TO CM-STATE(WS-BASE + WS-I + 1)
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-NBT-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-NBT-PALETTE-ENTRY.
*> USING PB-BUFFER, element type (BINARY-LONG), key out (PIC X(32)), key length out, properties out
*> (PIC X(64): "name=value" pairs separated by ","), pair count out: one compound palette entry
*> (07 §7.3): {id, properties} or the wrapper {"": key} of a mixed list (07 §1.1). An element of
*> another type is skipped (no key: void).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-PVALUE              PIC X(32).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ELEMENT-TYPE         BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-PAIRS                PIC X(64).
 01 L-PAIR-COUNT           BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ELEMENT-TYPE L-KEY L-KEY-LENGTH L-PAIRS L-PAIR-COUNT.
     MOVE 1 TO WS-PTR
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN (WN = "id" OR WN = SPACES) AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER L-KEY WS-CAPACITY L-KEY-LENGTH
             WHEN WN = "properties" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY
                         WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     MOVE SPACES TO WS-PVALUE
                     MOVE 0 TO WS-PVALUE-LENGTH
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-PVALUE WS-CAPACITY
                         WS-PVALUE-LENGTH
                     IF L-PAIR-COUNT > 0
                         STRING "," DELIMITED BY SIZE INTO L-PAIRS WITH POINTER WS-PTR
                     END-IF
                     STRING WN DELIMITED BY SPACE "=" DELIMITED BY SIZE
                         WS-PVALUE DELIMITED BY SPACE INTO L-PAIRS WITH POINTER WS-PTR
                     ADD 1 TO L-PAIR-COUNT
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-NBT-PALETTE-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-NBT-BLOCK-STATE.
*> USING key (PIC X(32), space filled), properties (PIC X(64), "name=value" pairs separated by ","),
*> pair count, state out (BINARY-LONG): the block state the palette entry names (BLOCKS.cpy): the
*> block of that key (void for an unknown key), its state whose SB-PROPS has exactly those pairs in
*> any order, else its default state (also when there are no properties).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKS.
 01 WS-B                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-EQUALS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PAIR                PIC X(32).
 01 WS-PAIR-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-PAIRS                PIC X(64).
 01 L-PAIR-COUNT           BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-PAIR-COUNT L-STATE.
     MOVE 0 TO WS-BLOCK
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > BLOCK-COUNT
         IF BL-KEY(WS-B) = L-KEY
             COMPUTE WS-BLOCK = WS-B - 1
         END-IF
     END-PERFORM
     MOVE BL-DEFAULT-STATE(WS-BLOCK + 1) TO L-STATE
     PERFORM VARYING WS-S FROM BL-FIRST-STATE(WS-BLOCK + 1) BY 1
             UNTIL WS-S >= BL-FIRST-STATE(WS-BLOCK + 1) + BL-STATE-COUNT(WS-BLOCK + 1)
                 OR L-PAIR-COUNT = 0
         MOVE 0 TO WS-MATCHED WS-EQUALS
         INSPECT SB-PROPS(WS-S + 1) TALLYING WS-EQUALS FOR ALL "="
         MOVE 1 TO WS-PTR
         PERFORM L-PAIR-COUNT TIMES
             MOVE SPACES TO WS-PAIR
             UNSTRING L-PAIRS DELIMITED BY "," OR SPACE INTO WS-PAIR COUNT WS-PAIR-LENGTH
                 WITH POINTER WS-PTR
             END-UNSTRING
             MOVE 0 TO WS-FOUND
             INSPECT SB-PROPS(WS-S + 1) TALLYING WS-FOUND
                 FOR ALL WS-PAIR(1:WS-PAIR-LENGTH)
             IF WS-FOUND > 0
                 ADD 1 TO WS-MATCHED
             END-IF
         END-PERFORM
         IF WS-MATCHED = L-PAIR-COUNT AND WS-EQUALS = L-PAIR-COUNT
             MOVE WS-S TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-NBT-BLOCK-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-WRITE.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), PB-BUFFER (appended to): the entities/ chunk
*> payload (07 §9.3) of that chunk: DataVersion, Position [chunk x, chunk z] and Entities, one
*> compound per mob and ground item of that dimension whose position is in the chunk, in tracker
*> order: id, Pos, Motion, Rotation, then Health (mobs) or Item {id, count} and Age (ground items).
*> Players are not stored here (07 §9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 COPY ITEMS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-POSITION.
    05 WS-POSITION-INT     BINARY-LONG OCCURS 2 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "Position" TO WN MOVE 8 TO WL
     MOVE L-CX TO WS-POSITION-INT(1)
     MOVE L-CZ TO WS-POSITION-INT(2)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-TWO WS-POSITION
     MOVE "Entities" TO WN
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "id" TO WN MOVE 2 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL ET-KEY(EN-TYPE(WS-ROW) + 1)
                 ET-KEY-LENGTH(EN-TYPE(WS-ROW) + 1)
             MOVE "Pos" TO WN MOVE 3 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-X(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Y(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Z(WS-ROW)
             MOVE "Motion" TO WN MOVE 6 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VX(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VY(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VZ(WS-ROW)
             MOVE "Rotation" TO WN MOVE 8 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-FLOAT WS-TWO
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-YAW(WS-ROW)
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-PITCH(WS-ROW)
             IF EN-TYPE(WS-ROW) = ET-LOOSE-ITEM
                 MOVE "Item" TO WN MOVE 4 TO WL
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
                 MOVE "id" TO WN MOVE 2 TO WL
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL IT-KEY(EN-ITEM(WS-ROW) + 1)
                     IT-KEY-LENGTH(EN-ITEM(WS-ROW) + 1)
                 MOVE "count" TO WN MOVE 5 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ITEM-COUNT(WS-ROW)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 MOVE "Age" TO WN MOVE 3 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-AGE(WS-ROW)
             ELSE
                 MOVE "Health" TO WN MOVE 6 TO WL
                 MOVE EN-HEALTH(WS-ROW) TO WS-FLOAT
                 CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM ENTITY-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-READ.
*> USING dimension row (BINARY-LONG), PB-BUFFER (an entities/ chunk payload at PB-POS), outcome out
*> (BINARY-LONG: 0 read, 1 malformed): every entity of its Entities list enters that dimension
*> (ENTITY-NBT-ONE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER L-OUTCOME.
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "Entities" AND WS-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "ENTITY-NBT-ONE" USING L-DIM PB-BUFFER
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     MOVE PB-ERROR TO L-OUTCOME
     GOBACK.
 END PROGRAM ENTITY-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-ONE.
*> USING dimension row, PB-BUFFER (an entity compound payload at PB-POS, 07 §9.3): a ground item
*> (GI-SPAWN with its stack, position and motion, no pickup delay, then its Age and rotation) or a
*> mob (MOB-SPAWN with its type, position and yaw, then its health, pitch and vertical motion). An
*> entity of another type, or a malformed one, is not created.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 COPY MOBS.
 COPY ITEMS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTITY-TYPE         BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-COUNT          BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-HEALTH              FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER.
     MOVE -1 TO WS-ENTITY-TYPE
     MOVE 0 TO WS-ITEM WS-ITEM-COUNT WS-AGE WS-DELAY WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ
     MOVE 0 TO WS-YAW WS-PITCH WS-HEALTH
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-CAPACITY WS-KEY-LENGTH
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ENTITY-TYPE-COUNT
                     IF ET-KEY(WS-I) = WS-KEY
                         COMPUTE WS-ENTITY-TYPE = WS-I - 1
                     END-IF
                 END-PERFORM
             WHEN WN = "Pos" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
             WHEN WN = "Motion" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VX
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VY
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VZ
             WHEN WN = "Rotation" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-YAW
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PITCH
             WHEN WN = "Health" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-HEALTH
             WHEN WN = "Age" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-AGE
             WHEN WN = "Item" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY
                         WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "id" AND WS-INNER-TYPE = 8
                             MOVE SPACES TO WS-KEY
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-CAPACITY
                                 WS-KEY-LENGTH
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ITEM-COUNT
                                 IF IT-KEY(WS-I) = WS-KEY
                                     COMPUTE WS-ITEM = WS-I - 1
                                 END-IF
                             END-PERFORM
                         WHEN WN = "count" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-ITEM-COUNT
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     EVALUATE TRUE
         WHEN PB-ERROR = 1
             CONTINUE
         WHEN WS-ENTITY-TYPE = ET-LOOSE-ITEM
             CALL "GI-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ITEM-COUNT
                 WS-DELAY WS-ROW
             MOVE WS-AGE TO EN-AGE(WS-ROW)
             MOVE WS-YAW TO EN-YAW(WS-ROW)
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
         WHEN WS-ENTITY-TYPE >= MOB-FIRST-TYPE
             CALL "MOB-SPAWN" USING L-DIM WS-ENTITY-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
             COMPUTE EN-HEALTH(WS-ROW) ROUNDED = WS-HEALTH
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             MOVE WS-VY TO EN-VY(WS-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-NBT-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-PATH.
*> USING suffix (PIC X(128): the path inside the world folder, starting with "/", space filled),
*> path out (PIC X(1100), space filled), path length out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-SUFFIX               PIC X(128).
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SUFFIX L-PATH L-LENGTH.
     MOVE SPACES TO L-PATH
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) FUNCTION TRIM(L-SUFFIX) DELIMITED BY SIZE INTO L-PATH
     COMPUTE L-LENGTH = CW-FOLDER-LENGTH + FUNCTION LENGTH(FUNCTION TRIM(L-SUFFIX))
     GOBACK.
 END PROGRAM PERSIST-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-READ-FILE.
*> USING path (PIC X(1100)), path length, PB-BUFFER (initialised): reads the gzip NBT file
*> (NBT-FILE-READ) and its file root header; PB-POS is left at the root compound payload. A file
*> that is missing or cannot be read as gzip NBT is fatal (research R14): "world: cannot read
*> <path>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FATAL               PIC X(1200).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH PB-BUFFER.
     CALL "NBT-FILE-READ" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         MOVE LOW-VALUES TO WS-FATAL
         STRING "world: cannot read " L-PATH(1:L-LENGTH) DELIMITED BY SIZE INTO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     GOBACK.
 END PROGRAM PERSIST-READ-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-WRITE-FILE.
*> USING path (PIC X(1100)), path length, PB-BUFFER (a named-root NBT stream): writes the gzip NBT
*> file (NBT-FILE-WRITE); the outcome goes to PERSIST-WRITE-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH PB-BUFFER.
     CALL "NBT-FILE-WRITE" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
     CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME L-PATH L-LENGTH
     GOBACK.
 END PROGRAM PERSIST-WRITE-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-WRITE-CHECK.
*> USING outcome (BINARY-LONG, 0 written), path (PIC X(1100): the file, or the region folder),
*> path length: the check after every write of the world folder. A failed write is fatal
*> (research R14): "world save: cannot write <path>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FATAL               PIC X(1200).
 LINKAGE SECTION.
 01 L-OUTCOME              BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-OUTCOME L-PATH L-LENGTH.
     IF L-OUTCOME NOT = 0
         MOVE LOW-VALUES TO WS-FATAL
         STRING "world save: cannot write " L-PATH(1:L-LENGTH) DELIMITED BY SIZE INTO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM PERSIST-WRITE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-UUID-TEXT.
*> USING offline UUID (PIC X(16)), text out (PIC X(36)): hyphenated lower-case hex (07 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX                 PIC X(16) VALUE "0123456789abcdef".
 01 WS-I                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-TEXT                 PIC X(36).
 PROCEDURE DIVISION USING L-UUID L-TEXT.
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-BYTE = FUNCTION ORD(L-UUID(WS-I:1)) - 1
         COMPUTE WS-HIGH = WS-BYTE / 16
         MOVE WS-HEX(WS-HIGH + 1:1) TO L-TEXT(WS-PTR:1)
         MOVE WS-HEX(WS-BYTE - WS-HIGH * 16 + 1:1) TO L-TEXT(WS-PTR + 1:1)
         ADD 2 TO WS-PTR
         IF WS-I = 4 OR WS-I = 6 OR WS-I = 8 OR WS-I = 10
             MOVE "-" TO L-TEXT(WS-PTR:1)
             ADD 1 TO WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-UUID-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-UUID-INTS.
*> USING direction (BINARY-LONG: 0 UUID to Ints, 1 Ints to UUID), offline UUID (PIC X(16)), Ints
*> (table of 4 BINARY-LONG): the UUID as four signed big-endian Ints, most significant first
*> (07 §9.2, Open question 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-FOUR                PIC X(4).
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-INTS.
    05 L-INT               BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-DIRECTION L-UUID L-INTS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF L-DIRECTION = 0
             MOVE L-UUID(WS-I * 4 - 3:4) TO WS-FOUR
             CALL "REGION-BE-GET" USING WS-FOUR WS-VALUE
             IF WS-VALUE >= 2147483648
                 SUBTRACT 4294967296 FROM WS-VALUE
             END-IF
             MOVE WS-VALUE TO L-INT(WS-I)
         ELSE
             MOVE L-INT(WS-I) TO WS-VALUE
             IF WS-VALUE < 0
                 ADD 4294967296 TO WS-VALUE
             END-IF
             CALL "REGION-BE-PUT" USING WS-VALUE WS-FOUR
             MOVE WS-FOUR TO L-UUID(WS-I * 4 - 3:4)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-UUID-INTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-DAT-WRITE.
*> No parameters: writes <world>/level.dat (07 §9.2): DataVersion, LevelName, GameMode, Time,
*> Spawn {Dimension (always cobolcraft:main, standin §5.2), X, Y, Z, Yaw} and Weather (an entry
*> named by the dimension key, {Kind, Remaining}, for every enabled dimension that has weather).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-INT                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/level.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "LevelName" TO WN MOVE 9 TO WL
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CW-NAME TRAILING)) TO WS-INT
     IF CW-NAME = SPACES
         MOVE 0 TO WS-INT
     END-IF
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL CW-NAME WS-INT
     MOVE "GameMode" TO WN MOVE 8 TO WL
     MOVE CW-GAME-MODE TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "Time" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-TIME
     MOVE "Spawn" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Dimension" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL DM-KEY(DIM-MAIN) DM-KEY-LENGTH(DIM-MAIN)
     MOVE "X" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-X
     MOVE "Y" TO WN
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-Y
     MOVE "Z" TO WN
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-Z
     MOVE "Yaw" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL CW-SPAWN-YAW
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "Weather" TO WN MOVE 7 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         IF DM-WEATHER(WS-DIM) = 1
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER DM-KEY(WS-DIM)
                 DM-KEY-LENGTH(WS-DIM)
             MOVE "Kind" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WK-KEY(CW-WEATHER-KIND(WS-DIM))
                 WK-KEY-LENGTH(CW-WEATHER-KIND(WS-DIM))
             MOVE "Remaining" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CW-WEATHER-LEFT(WS-DIM)
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM LEVEL-DAT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-DAT-READ.
*> No parameters: reads <world>/level.dat into the world (07 §9.2): LevelName, GameMode, Time, the
*> spawn point and the weather of every dimension it names that the game knows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/level.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "LevelName" AND WS-TYPE = 8
                 MOVE SPACES TO CW-NAME
                 CALL "NBT-READ-STRING" USING PB-BUFFER CW-NAME WS-TEXT-CAPACITY WS-INT
             WHEN WN = "GameMode" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO CW-GAME-MODE
             WHEN WN = "Time" AND WS-TYPE = 4
                 CALL "PB-GET-LONG" USING PB-BUFFER CW-TIME
             WHEN WN = "Spawn" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                         WS-NAME-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "X" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-X
                         WHEN WN = "Y" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-Y
                         WHEN WN = "Z" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-Z
                         WHEN WN = "Yaw" AND WS-INNER-TYPE = 5
                             CALL "PB-GET-FLOAT" USING PB-BUFFER CW-SPAWN-YAW
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN WN = "Weather" AND WS-TYPE = 10
*>               One compound per dimension key: {Kind, Remaining}.
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                         WS-NAME-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     MOVE 0 TO WS-DIM WS-KIND
                     MOVE WEATHER-UNTIL-CHANGED TO WS-LEFT
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
                         IF DM-KEY(WS-I) = WN
                             MOVE WS-I TO WS-DIM
                         END-IF
                     END-PERFORM
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                             WS-NAME-CAPACITY WL
                         IF WS-INNER-TYPE = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "Kind" AND WS-INNER-TYPE = 8
                                 MOVE SPACES TO WS-KEY
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-NAME-CAPACITY
                                     WS-KEY-LENGTH
                                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WEATHER-KIND-COUNT
                                     IF WK-KEY(WS-I) = WS-KEY
                                         MOVE WS-I TO WS-KIND
                                     END-IF
                                 END-PERFORM
                             WHEN WN = "Remaining" AND WS-INNER-TYPE = 3
                                 CALL "PB-GET-INT" USING PB-BUFFER WS-LEFT
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                         END-EVALUATE
                     END-PERFORM
                     IF WS-DIM > 0 AND WS-KIND > 0
                         MOVE WS-KIND TO CW-WEATHER-KIND(WS-DIM)
                         MOVE WS-LEFT TO CW-WEATHER-LEFT(WS-DIM)
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM LEVEL-DAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-DAT-WRITE.
*> No parameters: writes <world>/access.dat (07 §9.2): DataVersion; Operators, Bans and AllowList,
*> each a list of {Name, UUID: Int Array of 4}; AllowListEnforced.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TO-INTS             BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-INT                 BINARY-LONG.
 01 WS-INTS.
    05 WS-INT-ITEM         BINARY-LONG OCCURS 4 TIMES.
 01 WS-LIST-NAMES.
    05 FILLER              PIC X(16) VALUE "Operators".
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              PIC X(16) VALUE "Bans".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              PIC X(16) VALUE "AllowList".
    05 FILLER              BINARY-LONG VALUE 9.
 01 WS-LIST-TABLE REDEFINES WS-LIST-NAMES.
    05 WS-LIST-ENTRY OCCURS 3 TIMES.
       10 WS-LIST-NAME     PIC X(16).
       10 WS-LIST-LENGTH   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/access.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 3
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-LIST-NAME(WS-L) WS-LIST-LENGTH(WS-L)
             WS-T-COMPOUND AC-COUNT(WS-L)
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > AC-COUNT(WS-L)
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "Name" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL AC-NAME(WS-L, WS-ROW)
                 AC-NAME-LENGTH(WS-L, WS-ROW)
             MOVE "UUID" TO WN
             CALL "PERSIST-UUID-INTS" USING WS-TO-INTS AC-UUID(WS-L, WS-ROW) WS-INTS
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-PERFORM
     MOVE "AllowListEnforced" TO WN MOVE 17 TO WL
     MOVE AC-ENFORCED TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM ACCESS-DAT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-DAT-READ.
*> No parameters: reads <world>/access.dat into the access lists (every list emptied first; entries
*> past CORE-MAX-ACCESS are dropped by ACCESS-ADD) and the enforcement flag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT-ITEM         BINARY-LONG OCCURS 4 TIMES.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME-SIZE           BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16).
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/access.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     INITIALIZE CORE-ACCESS
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Operators"
                 MOVE ACCESS-OPERATORS TO WS-LIST
             WHEN WN = "Bans"
                 MOVE ACCESS-BANS TO WS-LIST
             WHEN WN = "AllowList"
                 MOVE ACCESS-ALLOW TO WS-LIST
             WHEN OTHER
                 MOVE 0 TO WS-LIST
         END-EVALUATE
         EVALUATE TRUE
             WHEN WS-LIST > 0 AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-NAME
                     MOVE LOW-VALUES TO WS-UUID
                     MOVE 0 TO WS-NAME-LENGTH
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                             WS-NAME-CAPACITY WL
                         IF WS-INNER-TYPE = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "Name" AND WS-INNER-TYPE = 8
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-NAME WS-NAME-SIZE
                                     WS-NAME-LENGTH
                             WHEN WN = "UUID" AND WS-INNER-TYPE = 11
                                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY
                                     WS-INT-COUNT WS-INTS
                                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID WS-UUID WS-INTS
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                         END-EVALUATE
                     END-PERFORM
                     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
                 END-PERFORM
             WHEN WN = "AllowListEnforced" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO AC-ENFORCED
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM ACCESS-DAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-DAT-WRITE.
*> USING known-player row (BINARY-LONG; CORESTATE CORE-KNOWN with its stored state): writes
*> <world>/players/<offline-uuid>.dat (07 §9.2): DataVersion, Name, Dimension, Pos, Rotation,
*> GameMode, Health, Food, Inventory (one {Slot, id, count} per non-empty slot, in slot order) and
*> HeldSlot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY ITEMS.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-INT                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-INVENTORY.
    05 WS-SLOT OCCURS 36 TIMES.
       10 WS-SLOT-ITEM     BINARY-LONG.
       10 WS-SLOT-COUNT    BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-SUFFIX              PIC X(128).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-KNOWN.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE KN-INVENTORY(L-KNOWN) TO WS-INVENTORY
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "Name" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL KN-NAME(L-KNOWN) KN-NAME-LENGTH(L-KNOWN)
     MOVE "Dimension" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL DM-KEY(KN-DIM(L-KNOWN))
         DM-KEY-LENGTH(KN-DIM(L-KNOWN))
     MOVE "Pos" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT KN-X(L-KNOWN)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT KN-Y(L-KNOWN)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT KN-Z(L-KNOWN)
     MOVE "Rotation" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-FLOAT WS-TWO
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT KN-YAW(L-KNOWN)
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT KN-PITCH(L-KNOWN)
     MOVE "GameMode" TO WN MOVE 8 TO WL
     MOVE KN-MODE(L-KNOWN) TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "Health" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL KN-HEALTH(L-KNOWN)
     MOVE "Food" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL KN-FOOD(L-KNOWN)
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF WS-SLOT-COUNT(WS-S) > 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "Inventory" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF WS-SLOT-COUNT(WS-S) > 0
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "Slot" TO WN MOVE 4 TO WL
             COMPUTE WS-INT = WS-S - 1
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
             MOVE "id" TO WN MOVE 2 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL IT-KEY(WS-SLOT-ITEM(WS-S) + 1)
                 IT-KEY-LENGTH(WS-SLOT-ITEM(WS-S) + 1)
             MOVE "count" TO WN MOVE 5 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-SLOT-COUNT(WS-S)
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     MOVE "HeldSlot" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL KN-HELD(L-KNOWN)
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-UUID-TEXT" USING KN-UUID(L-KNOWN) WS-UUID-TEXT
     MOVE SPACES TO WS-SUFFIX
     STRING "/players/" WS-UUID-TEXT ".dat" DELIMITED BY SIZE INTO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM PLAYER-DAT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-DAT-READ.
*> USING offline UUID (PIC X(16)), known-player row out (BINARY-LONG; 0 when the world has no file
*> for that UUID, or the known-player table is full): reads players/<offline-uuid>.dat into a new
*> known-player row: its stored state (KN-STORED 1, not dirty) and the place it left from
*> (KN-PLACED 1; a Dimension the game does not know leaves KN-DIM 0, so the player starts at the
*> world spawn). Stored with health 0, the player left while dead (standin §10.6); the file keeps no
*> death cause, so the death screen shows the cause-less message of CAUSE-COMMAND (health set to 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY ITEMS.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-NAME-SIZE           BINARY-LONG VALUE 16.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SLOT-NUMBER         BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-COUNT          BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-INVENTORY.
    05 WS-SLOT OCCURS 36 TIMES.
       10 WS-SLOT-ITEM     BINARY-LONG.
       10 WS-SLOT-COUNT    BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-SUFFIX              PIC X(128).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-FILE-INFO           PIC X(16).
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-UUID L-KNOWN.
     MOVE 0 TO L-KNOWN
     CALL "PERSIST-UUID-TEXT" USING L-UUID WS-UUID-TEXT
     MOVE SPACES TO WS-SUFFIX
     STRING "/players/" WS-UUID-TEXT ".dat" DELIMITED BY SIZE INTO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-FILE-INFO
     IF RETURN-CODE NOT = 0 OR KN-COUNT >= CORE-MAX-KNOWN
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     ADD 1 TO KN-COUNT
     MOVE KN-COUNT TO L-KNOWN
     INITIALIZE KN-PLACE(L-KNOWN) KN-STATE(L-KNOWN)
     MOVE L-UUID TO KN-UUID(L-KNOWN)
     MOVE 0 TO KN-DEATH-CAUSE(L-KNOWN) KN-KILLER-LENGTH(L-KNOWN)
     MOVE SPACES TO KN-KILLER-NAME(L-KNOWN)
     INITIALIZE WS-INVENTORY
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Name" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER KN-NAME(L-KNOWN) WS-NAME-SIZE
                     KN-NAME-LENGTH(L-KNOWN)
             WHEN WN = "Dimension" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-NAME-CAPACITY WS-KEY-LENGTH
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
                     IF DM-KEY(WS-I) = WS-KEY
                         MOVE WS-I TO KN-DIM(L-KNOWN)
                     END-IF
                 END-PERFORM
             WHEN WN = "Pos" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KN-X(L-KNOWN)
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KN-Y(L-KNOWN)
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KN-Z(L-KNOWN)
             WHEN WN = "Rotation" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-FLOAT" USING PB-BUFFER KN-YAW(L-KNOWN)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER KN-PITCH(L-KNOWN)
             WHEN WN = "GameMode" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO KN-MODE(L-KNOWN)
             WHEN WN = "Health" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER KN-HEALTH(L-KNOWN)
             WHEN WN = "Food" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER KN-FOOD(L-KNOWN)
             WHEN WN = "HeldSlot" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER KN-HELD(L-KNOWN)
             WHEN WN = "Inventory" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE -1 TO WS-SLOT-NUMBER
                     MOVE 0 TO WS-ITEM WS-ITEM-COUNT
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                             WS-NAME-CAPACITY WL
                         IF WS-INNER-TYPE = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "Slot" AND WS-INNER-TYPE = 1
                                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-SLOT-NUMBER
                             WHEN WN = "id" AND WS-INNER-TYPE = 8
                                 MOVE SPACES TO WS-KEY
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-NAME-CAPACITY
                                     WS-KEY-LENGTH
                                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > ITEM-COUNT
                                     IF IT-KEY(WS-K) = WS-KEY
                                         COMPUTE WS-ITEM = WS-K - 1
                                     END-IF
                                 END-PERFORM
                             WHEN WN = "count" AND WS-INNER-TYPE = 3
                                 CALL "PB-GET-INT" USING PB-BUFFER WS-ITEM-COUNT
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                         END-EVALUATE
                     END-PERFORM
                     IF WS-SLOT-NUMBER >= 0 AND WS-SLOT-NUMBER <= 35 AND WS-ITEM > 0
                         MOVE WS-ITEM TO WS-SLOT-ITEM(WS-SLOT-NUMBER + 1)
                         MOVE WS-ITEM-COUNT TO WS-SLOT-COUNT(WS-SLOT-NUMBER + 1)
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE WS-INVENTORY TO KN-INVENTORY(L-KNOWN)
     MOVE 1 TO KN-STORED(L-KNOWN) KN-PLACED(L-KNOWN)
     MOVE 0 TO KN-DIRTY(L-KNOWN)
     IF KN-HEALTH(L-KNOWN) <= 0
         MOVE CAUSE-COMMAND TO KN-DEATH-CAUSE(L-KNOWN)
     END-IF
     GOBACK.
 END PROGRAM PLAYER-DAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-DIM-DIR.
*> USING dimension row (BINARY-LONG), kind (PIC X(8): "region" or "entities"), folder out
*> (PIC X(1024), space filled), folder length out: <world>/dimensions/<namespace>/<path>/<kind>,
*> the dimension key split at its colon (07 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-KEY                 PIC X(32).
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KIND                 PIC X(8).
 01 L-DIR                  PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KIND L-DIR L-LENGTH.
     MOVE DM-KEY(L-DIM) TO WS-KEY
     INSPECT WS-KEY REPLACING FIRST ":" BY "/"
     MOVE SPACES TO L-DIR
     MOVE 1 TO WS-PTR
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/" WS-KEY(1:DM-KEY-LENGTH(L-DIM)) "/"
         L-KIND DELIMITED BY SPACE INTO L-DIR WITH POINTER WS-PTR
     COMPUTE L-LENGTH = WS-PTR - 1
     GOBACK.
 END PROGRAM PERSIST-DIM-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-DIRS.
*> No parameters: creates the folders of the world (07 §9.1) that do not exist yet: the world
*> folder, players/, and for every enabled dimension dimensions/<namespace>/<path>/ with region/ and
*> entities/. A folder that cannot be created shows up as a failed write later.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(1100).
 01 WS-KEY                 PIC X(32).
 01 WS-NAMESPACE           PIC X(32).
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-NAME
     MOVE CW-FOLDER(1:CW-FOLDER-LENGTH) TO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/players" DELIMITED BY SIZE INTO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     MOVE SPACES TO WS-NAME
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions" DELIMITED BY SIZE INTO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         MOVE DM-KEY(WS-DIM) TO WS-KEY
         MOVE SPACES TO WS-NAMESPACE
         UNSTRING WS-KEY DELIMITED BY ":" INTO WS-NAMESPACE
         MOVE SPACES TO WS-NAME
         STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/" WS-NAMESPACE DELIMITED BY SPACE
             INTO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         CALL "PERSIST-DIM-DIR" USING WS-DIM WS-REGION WS-DIR WS-LENGTH
         MOVE SPACES TO WS-NAME
         MOVE WS-DIR(1:WS-LENGTH - 7) TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         MOVE WS-DIR TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         CALL "PERSIST-DIM-DIR" USING WS-DIM WS-ENTITIES WS-DIR WS-LENGTH
         MOVE WS-DIR TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM PERSIST-DIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-CHUNK-SAVE.
*> USING cache row: writes the chunk into its dimension's region file (CHUNK-NBT-WRITE,
*> REGION-WRITE; the outcome goes to PERSIST-WRITE-CHECK) and clears its changed flag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-NBT-WRITE" USING L-ROW PB-BUFFER
     CALL "PERSIST-DIM-DIR" USING CK-DIM(L-ROW) WS-REGION WS-DIR WS-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-LENGTH CK-X(L-ROW) CK-Z(L-ROW) PB-BUFFER WS-OUTCOME
     MOVE WS-DIR TO WS-PATH
     CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH
     MOVE 0 TO CK-CHANGED(L-ROW)
     GOBACK.
 END PROGRAM PERSIST-CHUNK-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-CHUNK-LOAD.
*> USING cache row (its dimension and coordinates set, memory allocated), found out (BINARY-LONG):
*> 1 when the dimension's region file holds the chunk and it reads (CHUNK-NBT-READ), else 0 (the
*> caller generates it). A chunk that is absent or malformed in its region file is generated again
*> (07 §6.3: such chunks read as absent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO L-FOUND
     CALL "PERSIST-DIM-DIR" USING CK-DIM(L-ROW) WS-REGION WS-DIR WS-LENGTH
     CALL "REGION-READ" USING WS-DIR WS-LENGTH CK-X(L-ROW) CK-Z(L-ROW) PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME = 0
         CALL "CHUNK-NBT-READ" USING L-ROW PB-BUFFER WS-OUTCOME
         COMPUTE L-FOUND = 1 - WS-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM PERSIST-CHUNK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-SAVE.
*> USING dimension row: replaces the dimension's entities/ region files: every region file there is
*> deleted, then each chunk that holds mobs or ground items gets its payload (ENTITY-NBT-WRITE). A
*> chunk whose entities all left or vanished therefore holds none after the save.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-CHUNKS.
    05 WS-CHUNK OCCURS 1024 TIMES.
       10 WS-CHUNK-X       BINARY-LONG.
       10 WS-CHUNK-Z       BINARY-LONG.
 01 WS-CHUNK-COUNT         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         MOVE SPACES TO WS-PATH
         STRING WS-DIR(1:WS-LENGTH) "/" WS-ENTRY(2:255) DELIMITED BY SIZE INTO WS-PATH
         CALL "CBL_DELETE_FILE" USING WS-PATH
     END-PERFORM
     MOVE 0 TO RETURN-CODE
*>   The distinct chunks that hold this dimension's mobs and ground items.
     MOVE 0 TO WS-CHUNK-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
                 IF WS-CHUNK-X(WS-K) = WS-CX AND WS-CHUNK-Z(WS-K) = WS-CZ
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-CHUNK-COUNT
                 MOVE WS-CX TO WS-CHUNK-X(WS-CHUNK-COUNT)
                 MOVE WS-CZ TO WS-CHUNK-Z(WS-CHUNK-COUNT)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-DIR TO WS-PATH
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
         CALL "PB-RESET" USING PB-BUFFER
         CALL "ENTITY-NBT-WRITE" USING L-DIM WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
         CALL "REGION-WRITE" USING WS-DIR WS-LENGTH WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
             WS-OUTCOME
         CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-LOAD.
*> USING dimension row: every chunk payload of every entities/ region file of the dimension
*> (r.<rx>.<rz>.mca, 32 x 32 chunks each) enters the world (ENTITY-NBT-READ). The entity tracker
*> holds every entity of the world, so they are all loaded when the world opens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-PARTS.
    05 WS-PART             PIC X(32) OCCURS 4 TIMES.
 01 WS-ABS-X               BINARY-LONG.
 01 WS-ABS-Z               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY WS-PART(1) WS-PART(2) WS-PART(3) WS-PART(4)
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         UNSTRING WS-ENTRY(2:255) DELIMITED BY "." INTO WS-PART(1) WS-PART(2) WS-PART(3)
             WS-PART(4)
         COMPUTE WS-RX = FUNCTION NUMVAL(WS-PART(2))
         COMPUTE WS-RZ = FUNCTION NUMVAL(WS-PART(3))
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 31
             PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 31
                 COMPUTE WS-ABS-X = WS-RX * 32 + WS-CX
                 COMPUTE WS-ABS-Z = WS-RZ * 32 + WS-CZ
                 CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-ABS-X WS-ABS-Z PB-BUFFER WS-OUTCOME
                 IF WS-OUTCOME = 0
                     CALL "ENTITY-NBT-READ" USING L-DIM PB-BUFFER WS-OUTCOME
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-SAVE.
*> No parameters: writes the whole world (FR-014; 07 §9.5): every changed chunk, the entities of
*> every enabled dimension (PERSIST-ENTITIES-SAVE), the file of every player in play and of every
*> player who left since the previous save (KN-DIRTY), level.dat and access.dat.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PERSIST-DIRS"
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
         IF CK-USED(WS-ROW) = 1 AND CK-CHANGED(WS-ROW) = 1
             CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
         END-IF
     END-PERFORM
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         CALL "PERSIST-ENTITIES-SAVE" USING CW-DIM(WS-D)
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1
             IF CN-PHASE(PL-CONN(WS-ROW)) = PH-PLAY
                 CALL "PLAYER-REMEMBER" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > KN-COUNT
         IF KN-DIRTY(WS-ROW) = 1
             CALL "PLAYER-DAT-WRITE" USING WS-ROW
             MOVE 0 TO KN-DIRTY(WS-ROW)
         END-IF
     END-PERFORM
     CALL "LEVEL-DAT-WRITE"
     CALL "ACCESS-DAT-WRITE"
     GOBACK.
 END PROGRAM WORLD-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LOAD.
*> No parameters: reads an existing world folder (CORE-WORLD-OPEN, created flag 0): level.dat,
*> access.dat and the entities of every enabled dimension. Chunks are read from the region files
*> when first used (WORLD-CHUNK-LOAD), player files when the player joins (PLAYER-CREATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "LEVEL-DAT-READ"
     CALL "ACCESS-DAT-READ"
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         CALL "PERSIST-ENTITIES-LOAD" USING CW-DIM(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-LOAD.
