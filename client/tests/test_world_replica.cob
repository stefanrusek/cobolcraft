*> Implementation test of client/src/world-replica.cob (REPLICA-CHUNK-LOAD, WORLD-ROW, WORLD-ROW-NEW,
*> WORLD-CELL, WORLD-CLEAR; docs/protocol/06; standin-content §1.2, §5.2): chunks decoded with
*> CHUNK-SECTION-DECODE and LIGHT-DECODE are stored per chunk position with block and light lookup;
*> state ids the client does not know decode as void; a loaded chunk and its neighbours are marked to
*> be meshed; cells outside the loaded chunks are void under full sky light, below the world void
*> and dark; when every row is taken the row farthest from the player is reused. Changes (US4-7):
*> Section Blocks Update of a section at negative coordinates sets its cells (an unknown state
*> becomes void); Light Update takes an empty-mask section as all 0 and an array section's nibbles.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-REPLICA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CELLS.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-PATH24              PIC X(256) VALUE
     "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-standard-24-sections.hex".
 01 WS-SEEN.
    05 WS-SEEN-FLAG        PIC 9 OCCURS 256 TIMES.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex".
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-EIGHTEEN            BINARY-LONG VALUE 18.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-NON-EMPTY           BINARY-LONG.
 01 WS-STATES.
    05 WS-ST               BINARY-LONG OCCURS 4096 TIMES.
 01 WS-BIOMES.
    05 WS-BI               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 18 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 18 TIMES.
 01 WS-ARRAYS              PIC X(2048).
 01 WS-ARRAYS2             PIC X(2048).
 01 WS-DIRTY               PIC X(16).
 01 WS-DIRTY24             PIC X(24).
 01 WS-LONG                BINARY-DOUBLE VALUE -1048577.
 01 WS-ENTRY               BINARY-DOUBLE VALUE 82775.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LIGHT-ARRAYS        PIC X(4096).
 01 WS-E                   PIC -(5)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 3 TO RG-BIOMES
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     MOVE "world replica the spawn chunk (0, 0) is stored: baseplate, greystone, loam, turf, the "
         & "marker pillar cardstacks, lucite and glowtube" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1/0/0 2/0/0 3/0/0 4/0/0 9/0/0 8/0/0 12/0/14 13/0/15" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-X WS-Y WS-Z
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 1 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 51 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 52 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 8 TO WS-X WS-Z
     MOVE 55 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 57 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 58 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 59 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "world replica outside the loaded chunks: void under sky light 15; below the world: "
         & "void and dark" TO TL-CASE
     MOVE "0/15/0 0/0/0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE -1 TO WS-X
     MOVE 60 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 0 TO WS-X
     MOVE -1 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE ALL "0" TO WS-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         MOVE WR-DIRTY(WS-ROW, WS-S) TO WS-DIRTY(WS-S:1)
     END-PERFORM
     MOVE "world replica every section of a loaded chunk is to be meshed" TO TL-CASE
     MOVE WS-DIRTY TO TL-OBSERVED
     MOVE "1111111111111111" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hand-built chunk (1, 0): section 0 all state 40 (unknown to the client), the rest void;
*>   loading it marks the neighbour (0, 0) to be meshed again.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         MOVE 0 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-CX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-CX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-CZ
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "TEST-SECTIONS" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE 1 TO WS-SKY-STATE(WS-I) WS-BLOCK-STATE(WS-I)
     END-PERFORM
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-EIGHTEEN WS-SKY-STATES WS-ARRAYS WS-BLOCK-STATES
         WS-ARRAYS2
     MOVE 0 TO PB-POS
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     MOVE "world replica a state id the client does not know (40) decodes as void (standin §1.2); "
         & "the neighbour chunk is marked to be meshed" TO TL-CASE
     MOVE "0/0/0 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 16 TO WS-X
     MOVE 0 TO WS-Y WS-Z
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     STRING FUNCTION TRIM(TL-OBSERVED) " " WR-DIRTY(WS-ROW, 1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-CLEAR" USING CLIENT-STATE
     MOVE 0 TO WS-CX
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE 7 TO WS-CX
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW2
     MOVE "world replica after WORLD-CLEAR no chunk is loaded and the first row is reused" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ROW * 100 + WS-ROW2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every row taken: the row farthest from the player (at chunk 0, 0) is reused.
     MOVE 0 TO PL-X PL-Z
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-MAX-CHUNKS
         COMPUTE WS-CX = 40 + WS-I
         MOVE WS-I TO WS-CZ
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     END-PERFORM
*>   The farthest chunk has a mesh in section 3; the chunk asked for again keeps its own.
     MOVE 5 TO WR-OP-COUNT(CL-MAX-CHUNKS, 3)
     MOVE 0 TO WR-UPLOAD(CL-MAX-CHUNKS, 3)
     MOVE 7 TO WR-TR-COUNT(2, 3)
     MOVE 0 TO WR-UPLOAD(2, 3)
     MOVE 42 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW2
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE "world replica with every row taken, a new chunk takes the row of the farthest one"
         TO TL-CASE
     MOVE CL-MAX-CHUNKS TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "world replica a row taken from the farthest chunk drops its meshes (no vertices, "
         & "uploaded so); a chunk asked for again keeps its row and meshes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WR-OP-COUNT(WS-ROW, 3) TO WS-E
     STRING FUNCTION TRIM(WS-E) " " WR-UPLOAD(WS-ROW, 3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ROW2 TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " row " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE WR-TR-COUNT(2, 3) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) " " WR-UPLOAD(2, 3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 1 row 2 7 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section (-1, -1, -2) of a dimension from y -16: one entry, state 20 (unknown) at local
*>   (3, 7, 5), the block (-13, -9, -27), which held greystone.
     MOVE -16 TO PL-MIN-Y
     MOVE -1 TO WS-CX
     MOVE -2 TO WS-CZ
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE -13 TO WS-X
     MOVE -9 TO WS-Y
     MOVE -27 TO WS-Z
     MOVE 2 TO WS-STATE
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARLONG" USING PB-BUFFER WS-ENTRY
     MOVE 0 TO PB-POS
     CALL "WORLD-SECTION-BLOCKS" USING CLIENT-STATE PB-BUFFER
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) " " WR-DIRTY(WS-ROW, 1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "world replica Section Blocks Update of section (-1, -1, -2) sets (-13, -9, -27): greystone "
         & "becomes void (state 20 is unknown) and section 1 is to be meshed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Light Update of chunk (-1, -2): section 0 (index 2) an empty sky mask and a block array of
*>   bytes 0x5A (nibbles 10, 5).
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-CX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-CZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE 0 TO WS-SKY-STATE(WS-I) WS-BLOCK-STATE(WS-I)
     END-PERFORM
     MOVE 1 TO WS-SKY-STATE(2)
     MOVE 2 TO WS-BLOCK-STATE(2)
     MOVE ALL "Z" TO WS-LIGHT-ARRAYS
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-EIGHTEEN WS-SKY-STATES WS-ARRAYS WS-BLOCK-STATES
         WS-LIGHT-ARRAYS
     MOVE 0 TO PB-POS
     CALL "WORLD-LIGHT-UPDATE" USING CLIENT-STATE PB-BUFFER
     MOVE SPACES TO TL-OBSERVED
     MOVE -16 TO WS-X WS-Y
     MOVE -32 TO WS-Z
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE -15 TO WS-X
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE "world replica Light Update: an empty sky mask clears the section's sky light, a block "
         & "array sets the block light of each cell from its nibble (low nibble first)" TO TL-CASE
     MOVE "0/0/10 0/0/5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   T2940: a 24-section chunk through PB-GET-CHUNK-24 (the standard overworld, min_y -64, height
*>   384; 16-bit states, a content set of 35,724 states, 7-bit biomes). The fixture holds bedrock 88
*>   in the lowest 256 cells and stone above in sections 0 to 3, section 8 states i * 7 mod 35723,
*>   sky light 15 in light section 20 (y 240 to 255), block light 1 in light section 4.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     MOVE -64 TO PL-MIN-Y
     MOVE 384 TO PL-HEIGHT
     MOVE 65 TO RG-BIOMES
     MOVE 16 TO WR-BLOCK-BITS
     MOVE 1 TO CT-OPEN
     MOVE 35724 TO CT-STATE-COUNT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH24 PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     MOVE "world replica 24 sections: 16-bit states from min_y -64 (bedrock 88, stone, a state above 255 "
         & "in section 8, air above) and the light of sections the fixture sets" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "88/0/0 1/0/0 693/0/0 0/0/0 0/15/0 1/0/1 0/15/0 0/0/0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-X WS-Z
     MOVE -64 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE -48 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 3 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 64 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 0 TO WS-X WS-Z
     MOVE 224 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 240 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE -16 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 320 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE -65 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 8
         INITIALIZE WS-SEEN
         MOVE 0 TO WS-DISTINCT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             COMPUTE WS-J = CE-BIOME(WS-S * 64 + WS-I) + 1
             IF WS-SEEN-FLAG(WS-J) = 0
                 MOVE 1 TO WS-SEEN-FLAG(WS-J)
                 ADD 1 TO WS-DISTINCT
             END-IF
         END-PERFORM
         MOVE WS-DISTINCT TO WS-E
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
             INTO TL-OBSERVED
         MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     END-PERFORM
     MOVE "world replica 24 sections: the biome containers of sections 0 to 8 hold 1 2 2 2 4 8 64 1 1 "
         & "distinct biomes" TO TL-CASE
     MOVE "1 2 2 2 4 8 64 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ALL "0" TO WS-DIRTY24
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE WR-DIRTY(WS-ROW, WS-S) TO WS-DIRTY24(WS-S:1)
     END-PERFORM
     MOVE "world replica 24 sections: every one of the 24 sections is to be meshed" TO TL-CASE
     MOVE WS-DIRTY24 TO TL-OBSERVED
     MOVE "111111111111111111111111" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A packet cut short does not decode: the chunk is not in the replica.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "TEST-LOAD-HEX" USING WS-PATH24 PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     MOVE 5000 TO PB-LENGTH
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE "world replica a chunk packet that does not decode leaves the chunk out of the replica"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a content set open and no palette width given, the width is ceillog2 of its state count:
*>   the 19 states of the cobolcraft set are the 5 bits of the 001 form.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     MOVE 0 TO PL-MIN-Y
     MOVE 256 TO PL-HEIGHT
     MOVE 3 TO RG-BIOMES
     MOVE 0 TO WR-BLOCK-BITS
     MOVE 1 TO CT-OPEN
     MOVE 19 TO CT-STATE-COUNT
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     MOVE "world replica a content set open (19 states) and no palette width given: the width is 5 "
         & "and the spawn chunk decodes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1/0/0 2/0/0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-X WS-Y WS-Z
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     MOVE 1 TO WS-Y
     CALL "TEST-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN CT-STATE-COUNT WR-BLOCK-BITS
     STOP RUN.
 END PROGRAM TEST-WORLD-REPLICA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SECTIONS.
*> USING PB-BUFFER: the Data of 16 sections (size, then sections): section 0 all state 40, the
*> rest void, biomes 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SB-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-STATES.
    05 WS-ST               BINARY-LONG OCCURS 4096 TIMES.
 01 WS-BIOMES.
    05 WS-BI               BINARY-LONG OCCURS 64 TIMES VALUE 0.
 01 B-BYTES                PIC X(65536) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-INIT" USING SB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 15
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE 0 TO WS-ST(WS-I)
             IF WS-S = 0
                 MOVE 40 TO WS-ST(WS-I)
                 MOVE 4096 TO WS-COUNT
             END-IF
         END-PERFORM
         CALL "CHUNK-SECTION-ENCODE" USING SB-BUFFER WS-COUNT WS-ZERO WS-STATES WS-BIOMES WS-SIX
             WS-TWO
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER SB-LENGTH
     SET ADDRESS OF B-BYTES TO SB-ADDR
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BYTES SB-LENGTH
     CALL "PB-FREE" USING SB-BUFFER
     GOBACK.
 END PROGRAM TEST-SECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CELL.
*> USING CLIENT-STATE, x, y, z, text (appended): "<state>/<sky>/<block>" of the replica cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-E1                  PIC Z(4)9.
 01 WS-E2                  PIC Z9.
 01 WS-E3                  PIC Z9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-TEXT.
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     MOVE WS-SKY TO WS-E2
     MOVE WS-BLOCK TO WS-E3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/"
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-CELL.
 COPY CLTEST.
