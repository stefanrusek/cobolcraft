*> Implementation test of the on-disk chunk NBT (core/src/persistence.cob CHUNK-NBT-WRITE and
*> CHUNK-NBT-READ; docs/protocol/07-nbt-and-anvil.md §7 with the CobolCraft values of §9.4 and Open
*> question 9): the root keys, one section per 16 block layers with its Y, the block-state palette
*> (a default state as its block key, any other state as {id, properties}, a mixed list written as
*> compounds with the strings wrapped under "", 07 §1.1), the packed data (at least 4 bits, 07 §7.2)
*> only when the palette has more than one entry, the biome palette with its keys, no block
*> entities, LastUpdate = the world time, heightmaps (06 §3.1 widths), and a round trip that gives
*> back every block state and the light source counts of each section, in both dimensions. A
*> truncated stream reads as malformed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
  COPY REGISTRY.
 COPY CELLS.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-PROPS               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-TEXT                PIC X(8192).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-SAVED-STATES        PIC X(196608).
 01 WS-SAVED-SOURCES.
    05 WS-SAVED-SOURCE     BINARY-LONG OCCURS 16 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-SEEN                PIC X(3).
 01 WS-SEEN-STATES         PIC X(18).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EXPECTED-PALETTE    PIC X(256).
 01 WS-PALETTE-COUNT       BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 1234 TO CW-TIME

*>   Chunk (1, 2) of cobolcraft:main with three placed blocks in section 3 (y 48 to 63): a cardstack
*>   in a non-default state, an unlit glowtube (non-default) and lucite (its block's default state).
     MOVE DIM-MAIN TO WS-DIM
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 19 TO WS-X MOVE 60 TO WS-Y MOVE 36 TO WS-Z
     MOVE 6 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 20 TO WS-X MOVE 61 TO WS-Y
     MOVE 14 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 21 TO WS-X MOVE 62 TO WS-Y
     MOVE 12 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 22 TO WS-X MOVE 50 TO WS-Y
     MOVE 13 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM WRITE-CHUNK

     MOVE "test chunk nbt root keys: DataVersion 5023, xPos 1, yPos 0, zPos 2, LastUpdate = world "
         & "time 1234, InhabitedTime 0, Status minecraft:full" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "DataVersion" TO WS-PATH PERFORM ADD-GET
     MOVE "xPos" TO WS-PATH PERFORM ADD-GET
     MOVE "yPos" TO WS-PATH PERFORM ADD-GET
     MOVE "zPos" TO WS-PATH PERFORM ADD-GET
     MOVE "LastUpdate" TO WS-PATH PERFORM ADD-GET
     MOVE "InhabitedTime" TO WS-PATH PERFORM ADD-GET
     MOVE "Status" TO WS-PATH PERFORM ADD-GET
     MOVE "5023 1 0 2 1234 0 minecraft:full" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt: no block entities, empty block and fluid ticks, one empty PostProcessing "
         & "list per section, empty structures, no isLightOn" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "block_entities" TO WS-PATH PERFORM ADD-GET
     MOVE "block_ticks" TO WS-PATH PERFORM ADD-GET
     MOVE "fluid_ticks" TO WS-PATH PERFORM ADD-GET
     MOVE "PostProcessing" TO WS-PATH PERFORM ADD-GET
     MOVE "structures" TO WS-PATH PERFORM ADD-GET
     MOVE "isLightOn" TO WS-PATH PERFORM ADD-GET
     MOVE "[] [] [] [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]] {starts:{},References:{}} "
         & "absent" TO TL-EXPECTED
     PERFORM CHECK

*>   Heightmaps (06 §3.1): ceillog2(256 + 1) = 9 bits, 7 entries per Long, 37 Longs.
     MOVE "test chunk nbt heightmaps WORLD_SURFACE, MOTION_BLOCKING and MOTION_BLOCKING_NO_LEAVES "
         & "of 37 Longs each" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "Heightmaps" TO WS-PATH PERFORM ADD-GET
     MOVE "{WORLD_SURFACE:L37,MOTION_BLOCKING:L37,MOTION_BLOCKING_NO_LEAVES:L37}" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt: 16 sections, Y 0 to 15 in order" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 16
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-PATH
         STRING "sections[" FUNCTION TRIM(WS-EDIT) "].Y" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-GET
     END-PERFORM
     MOVE "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 absent" TO TL-EXPECTED
     PERFORM CHECK

*>   Section 3's palette in first-occurrence order (cell index y * 256 + z * 16 + x): the expected
*>   list is computed from the chunk memory, each state written as 07 §7.3 says.
     MOVE "test chunk nbt section 3 block-state palette: distinct states in first-occurrence order, "
         & "defaults wrapped as {:key}, others as {id:key,properties:{...}}" TO TL-CASE
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE LOW-VALUES TO WS-SEEN-STATES
     MOVE SPACES TO WS-TEXT
     MOVE "[" TO WS-TEXT
     MOVE 1 TO WS-N
     MOVE 0 TO WS-PALETTE-COUNT
     PERFORM VARYING WS-I FROM 12289 BY 1 UNTIL WS-I > 16384
         MOVE CE-STATE(WS-I) TO WS-STATE
         IF WS-SEEN-STATES(WS-STATE + 1:1) NOT = "1"
             MOVE "1" TO WS-SEEN-STATES(WS-STATE + 1:1)
             PERFORM ADD-PALETTE-ENTRY
         END-IF
     END-PERFORM
     MOVE "]" TO WS-TEXT(WS-N + 1:1)
     MOVE WS-TEXT TO WS-EXPECTED-PALETTE
     MOVE "sections[3].block_states.palette" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE WS-EXPECTED-PALETTE TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt section 3 data: ceil(4096 / floor(64 / bits)) Longs, bits = max(4, "
         & "ceillog2(palette size))" TO TL-CASE
     MOVE 4 TO WS-BITS
     IF WS-PALETTE-COUNT > 16
         MOVE 5 TO WS-BITS
     END-IF
     COMPUTE WS-N = 64 / WS-BITS
     COMPUTE WS-N = (4096 + WS-N - 1) / WS-N
     MOVE WS-N TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "L" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "sections[3].block_states.data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     PERFORM CHECK

     MOVE "test chunk nbt section 15 (all void): palette [cobolcraft:void] as a list of strings, "
         & "no data" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "sections[15].block_states.palette" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[15].block_states.data" TO WS-PATH PERFORM ADD-GET
     MOVE "[cobolcraft:void] absent" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt section 3 biomes: the generator's biome keys in first-occurrence order of "
         & "index y * 16 + z * 4 + x, data only with more than one" TO TL-CASE
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-BIOMES
     MOVE LOW-VALUES TO WS-SEEN
     MOVE SPACES TO TL-EXPECTED
     MOVE "[" TO TL-EXPECTED
     MOVE 1 TO WS-N
     MOVE 0 TO WS-PALETTE-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-SEEN(WS-BIOME(WS-I) + 1:1) NOT = "1"
             MOVE "1" TO WS-SEEN(WS-BIOME(WS-I) + 1:1)
             IF WS-PALETTE-COUNT > 0
                 MOVE "," TO TL-EXPECTED(WS-N + 1:1)
                 ADD 1 TO WS-N
             END-IF
             ADD 1 TO WS-PALETTE-COUNT
             MOVE RB-KEY(WS-BIOME(WS-I) + 1)(1:RB-KEY-LENGTH(WS-BIOME(WS-I) + 1))
                 TO TL-EXPECTED(WS-N + 1:RB-KEY-LENGTH(WS-BIOME(WS-I) + 1))
             ADD RB-KEY-LENGTH(WS-BIOME(WS-I) + 1) TO WS-N
         END-IF
     END-PERFORM
     MOVE "]" TO TL-EXPECTED(WS-N + 1:1)
     MOVE SPACES TO WS-TEXT
     EVALUATE WS-PALETTE-COUNT
         WHEN 1
             STRING FUNCTION TRIM(TL-EXPECTED) " absent" DELIMITED BY SIZE INTO WS-TEXT
         WHEN 2
             STRING FUNCTION TRIM(TL-EXPECTED) " L1" DELIMITED BY SIZE INTO WS-TEXT
         WHEN OTHER
             STRING FUNCTION TRIM(TL-EXPECTED) " L2" DELIMITED BY SIZE INTO WS-TEXT
     END-EVALUATE
     MOVE WS-TEXT TO TL-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     MOVE "sections[3].biomes.palette" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[3].biomes.data" TO WS-PATH PERFORM ADD-GET
     PERFORM CHECK

*>   Section 12 (y 192 to 207) gets every one of the 18 block states: a palette of 18 entries
*>   needs 5 bits (07 §7.2), so 12 entries per Long and 342 Longs.
     MOVE "test chunk nbt a section holding all 18 block states packs 5 bits per entry (342 "
         & "Longs)" TO TL-CASE
     PERFORM VARYING WS-STATE FROM 1 BY 1 UNTIL WS-STATE > 17
         COMPUTE WS-X = 16 + FUNCTION MOD(WS-STATE, 16)
         MOVE 200 TO WS-Y
         COMPUTE WS-Z = 32 + WS-STATE / 16
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     PERFORM WRITE-CHUNK
     MOVE "sections[12].block_states.data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE "L342" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt round trip of cobolcraft:main: every block state and each section's "
         & "light source count come back, the changed flag is clear" TO TL-CASE
     PERFORM ROUND-TRIP
     MOVE "0 same same 0" TO TL-EXPECTED
     PERFORM CHECK

*>   cobolcraft:subroutine (§15.1): height 128 (8 sections), biome ash_flats everywhere.
     MOVE "test chunk nbt cobolcraft:subroutine: 8 sections, biome palette [cobolcraft:ash_flats] "
         & "without data, round trip" TO TL-CASE
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE -3 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE -40 TO WS-X MOVE 40 TO WS-Y MOVE 5 TO WS-Z
     MOVE 16 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM WRITE-CHUNK
     MOVE SPACES TO WS-OBSERVED
     MOVE "xPos" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[7].Y" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[8]" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[2].biomes" TO WS-PATH PERFORM ADD-GET
     MOVE "Heightmaps.WORLD_SURFACE" TO WS-PATH PERFORM ADD-GET
     MOVE WS-OBSERVED TO WS-TEXT
     PERFORM ROUND-TRIP
     MOVE WS-OBSERVED TO WS-SAVED-STATES
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-SAVED-STATES(1:100)) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE "-3 7 absent {palette:[cobolcraft:ash_flats]} L32 0 same same 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk nbt a truncated stream reads as malformed (outcome 1)" TO TL-CASE
     PERFORM WRITE-CHUNK
     SUBTRACT 100 FROM PB-LENGTH
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The chunk of WS-ROW written into PB-BUFFER; WS-ROOT is its root payload position.
 WRITE-CHUNK.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-NBT-WRITE" USING WS-ROW PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.

*> Clears the chunk's states and light source counts, reads PB-BUFFER back: "<outcome> same|differ
*> same|differ <changed flag>" in WS-OBSERVED.
 ROUND-TRIP.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CE-STATES TO WS-SAVED-STATES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE CK-SOURCES(WS-ROW, WS-I) TO WS-SAVED-SOURCE(WS-I)
         MOVE 99 TO CK-SOURCES(WS-ROW, WS-I)
     END-PERFORM
     MOVE ALL X"07" TO CE-STATES
     MOVE 1 TO CK-CHANGED(WS-ROW)
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     IF CE-STATES = WS-SAVED-STATES
         STRING FUNCTION TRIM(WS-OBSERVED) " same" DELIMITED BY SIZE INTO WS-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-OBSERVED) " differ" DELIMITED BY SIZE INTO WS-OBSERVED
     END-IF
     MOVE "same" TO WS-TEXT(4001:4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF CK-SOURCES(WS-ROW, WS-I) NOT = WS-SAVED-SOURCE(WS-I)
             MOVE "diff" TO WS-TEXT(4001:4)
         END-IF
     END-PERFORM
     IF WS-TEXT(4001:4) = "same"
         STRING FUNCTION TRIM(WS-OBSERVED) " same" DELIMITED BY SIZE INTO WS-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-OBSERVED) " differ" DELIMITED BY SIZE INTO WS-OBSERVED
     END-IF
     MOVE SPACES TO WS-TEXT(4001:4)
     MOVE CK-CHANGED(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED.

*> Appends WS-STATE, in its 07 §7.3 form inside a mixed list, to the expected palette text in
*> WS-TEXT (WS-N characters used).
 ADD-PALETTE-ENTRY.
     IF WS-PALETTE-COUNT > 0
         MOVE "," TO WS-TEXT(WS-N + 1:1)
         ADD 1 TO WS-N
     END-IF
     ADD 1 TO WS-PALETTE-COUNT
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-X
     COMPUTE WS-PTR = WS-N + 1
     MOVE CB-KEY-LENGTH(WS-X + 1) TO WS-KEYLEN
     IF CB-DEFAULT-STATE(WS-X + 1) = WS-STATE
         STRING "{:" CB-KEY(WS-X + 1)(1:WS-KEYLEN) "}" DELIMITED BY SIZE
             INTO WS-TEXT POINTER WS-PTR
     ELSE
         CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
         MOVE WS-PROPS TO WS-PATH
         INSPECT WS-PATH REPLACING ALL "=" BY ":"
         STRING "{id:" CB-KEY(WS-X + 1)(1:WS-KEYLEN) ",properties:{"
             FUNCTION TRIM(WS-PATH) "}}" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     COMPUTE WS-N = WS-PTR - 1.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CHUNK-NBT.

 COPY CORETEST.
