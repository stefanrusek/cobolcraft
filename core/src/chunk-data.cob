*> Chunk persistence (07 section 7, 9.3): a chunk as Anvil NBT, written and read with block states by key in palettes
*> (CHUNK-NBT-*), and the region file load and save of one cached chunk (PERSIST-CHUNK-*). Split from persistence.cob (T0331).

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
 COPY CBLOCKS.
 COPY CELLS.
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
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PER                 BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-PAL-INDEXES.
    05 WS-PAL-INDEX        BINARY-LONG OCCURS 40000 TIMES.
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
 01 WS-PROPS               PIC X(64).
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
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
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
             MOVE CE-STATE(WS-BASE + WS-I) TO WS-STATE
             IF WS-PAL-INDEX(WS-STATE + 1) = 0
                 ADD 1 TO WS-N
                 MOVE WS-N TO WS-PAL-INDEX(WS-STATE + 1)
                 MOVE WS-STATE TO WS-PAL(WS-N)
                 IF CB-DEFAULT-STATE(CB-S-BLOCK(WS-STATE + 1) + 1) NOT = WS-STATE
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
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             CALL "PERSIST-NAMESPACED" USING CB-KEY(WS-BLOCK + 1) CB-KEY-LENGTH(WS-BLOCK + 1) WS-NS-KEY
                 WS-NS-LENGTH
             EVALUATE TRUE
                 WHEN WS-OTHERS = 0
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT WS-NS-KEY
                         WS-NS-LENGTH
                 WHEN CB-DEFAULT-STATE(WS-BLOCK + 1) = WS-STATE
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                     MOVE 0 TO WL
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY
                         WS-NS-LENGTH
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 WHEN OTHER
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                     MOVE "id" TO WN MOVE 2 TO WL
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY
                         WS-NS-LENGTH
                     MOVE "properties" TO WN MOVE 10 TO WL
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
                     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
                     MOVE 1 TO WS-PTR
                     PERFORM UNTIL WS-PTR > 64
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
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT CBI-KEY(WS-PAL(WS-K) + 1)
                 CBI-KEY-LENGTH(WS-PAL(WS-K) + 1)
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
*>       At most CBI-MAX biomes: 1 bit for 2 entries, 2 bits for 3 (07 §7.2 biome column).
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
     CALL "BE-CHUNK-WRITE" USING CK-DIM(L-ROW) CK-X(L-ROW) CK-Z(L-ROW) PB-BUFFER
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
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-CELLS               BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BE-POS              BINARY-LONG.
 01 WS-BE-COUNT            BINARY-LONG VALUE 0.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER L-OUTCOME.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE LOW-VALUES TO CE-STATES
     MOVE 0 TO CK-FOREIGN(L-ROW)
     MOVE 0 TO WS-BE-COUNT
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "sections" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     CALL "CHUNK-NBT-SECTION" USING L-ROW PB-BUFFER
                 END-PERFORM
*>           The block entities are read after the whole chunk, whatever the order of its keys (31-1 section 6 step 2).
             WHEN WN = "block_entities" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-BE-COUNT
                 MOVE PB-POS TO WS-BE-POS
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BE-COUNT OR PB-ERROR = 1
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ELEMENT-TYPE
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WS-BE-COUNT > 0 AND PB-ERROR = 0
         MOVE PB-POS TO WS-END
         MOVE WS-BE-POS TO PB-POS
         CALL "BE-CHUNK-READ" USING PB-BUFFER WS-BE-COUNT L-ROW
         MOVE WS-END TO PB-POS
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-MAX-SECTIONS
         MOVE 0 TO CK-SOURCES(L-ROW, WS-I)
     END-PERFORM
     COMPUTE WS-CELLS = DM-HEIGHT(CK-DIM(L-ROW)) * 256
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         IF CB-S-LIGHT(CE-STATE(WS-I) + 1) > 0
             ADD 1 TO CK-SOURCES(L-ROW, (WS-I - 1) / 4096 + 1)
         END-IF
     END-PERFORM
     MOVE 0 TO CK-CHANGED(L-ROW) CK-LIT(L-ROW)
     MOVE PB-ERROR TO L-OUTCOME
     IF CK-FOREIGN(L-ROW) = 1 AND PB-ERROR = 0
         MOVE 2 TO L-OUTCOME
     END-IF
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
 COPY CELLS.
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
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
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
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY
                                         WS-KEY-LENGTH
                                 ELSE
                                     CALL "CHUNK-NBT-PALETTE-ENTRY" USING PB-BUFFER WS-ELEMENT-TYPE
                                         WS-KEY WS-KEY-LENGTH WS-PAIRS WS-PAIR-COUNT
                                 END-IF
                                 CALL "CHUNK-NBT-BLOCK-STATE" USING WS-KEY WS-PAIRS WS-PAIR-COUNT
                                     WS-PAL(WS-K)
                                 IF WS-PAL(WS-K) < 0
                                     MOVE 1 TO CK-FOREIGN(L-ROW)
                                     MOVE 0 TO WS-PAL(WS-K)
                                 END-IF
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
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-Y = WS-Y - DM-MIN-Y(CK-DIM(L-ROW)) / 16
     IF WS-Y < 0 OR WS-Y >= DM-HEIGHT(CK-DIM(L-ROW)) / 16 OR WS-N = 0 OR PB-ERROR = 1
         GOBACK
     END-IF
     COMPUTE WS-BASE = WS-Y * 4096
     IF WS-N = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE WS-PAL(1) TO CE-STATE(WS-BASE + WS-I)
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
         MOVE WS-STATE TO CE-STATE(WS-BASE + WS-I + 1)
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
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-PVALUE              PIC X(32).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ELEMENT-TYPE         BINARY-LONG.
 01 L-KEY                  PIC X(64).
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
                 CALL "NBT-READ-STRING" USING PB-BUFFER L-KEY WS-KEY-CAPACITY L-KEY-LENGTH
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
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(64).
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-PAIRS                PIC X(64).
 01 L-PAIR-COUNT           BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-PAIR-COUNT L-STATE.
     MOVE SPACES TO WS-KEY WS-PAIRS
     MOVE L-KEY TO WS-KEY
     IF L-PAIR-COUNT > 0
         MOVE L-PAIRS TO WS-PAIRS
     END-IF
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     IF WS-ID < 0
         MOVE -1 TO L-STATE
         GOBACK
     END-IF
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM CHUNK-NBT-BLOCK-STATE.

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
     IF CK-FOREIGN(L-ROW) = 1
         MOVE 0 TO CK-CHANGED(L-ROW)
         GOBACK
     END-IF
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
*> 2 when the chunk holds a key of another world type (CK-FOREIGN, WT-23: not loaded, to be left as found);
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
         EVALUATE WS-OUTCOME
             WHEN 0
                 MOVE 1 TO L-FOUND
             WHEN 2
                 MOVE 2 TO L-FOUND
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM PERSIST-CHUNK-LOAD.
