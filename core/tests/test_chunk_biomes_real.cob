*> Real-data test (skipped as a pass without the generated packs; vanfmt lane; docs/protocol/07 section 7.1, 7.2): the biome cells of a chunk are saved as they
*> are in memory and read back (before, the writer took one biome per column from the generator and the reader dropped
*> them, so a loaded standard chunk lost its biomes). Cells of one section hold up to nine different biomes, the
*> palette lists them in first-occurrence order of the entry index y * 16 + z * 4 + x, the data is 1, 2, 3 or 4 bits
*> wide by palette size (07 section 7.2 table), and a round trip gives every cell of every section back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-BIOMES-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-SAVED               PIC X(1536).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
*>   A standard world with the generated packs: one section holding 12 different biomes needs 4-bit data
*>   (07 §7.2: 9 to 16 entries), and the round trip gives every cell back.
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
         MOVE "test chunk biomes real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE DIM-MAIN TO WS-DIM
     MOVE 40 TO WS-CX
     MOVE 40 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 63
         COMPUTE WS-BASE = 3 * 64 + WS-I + 1
         MOVE FUNCTION MOD(WS-I, 12) TO CE-BIOME(WS-BASE)
     END-PERFORM
     MOVE CE-BIOMES TO WS-SAVED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-NBT-WRITE" USING WS-ROW PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "T" TO TL-MODE
     MOVE "test chunk biomes real 12 biomes in a section are 4-bit data of 4 Longs (16 entries per Long)" TO TL-CASE
     MOVE "sections[3].biomes.data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE "L4" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ALL X"09" TO CE-BIOMES
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE "test chunk biomes real round trip of a standard chunk gives every biome cell back" TO TL-CASE
     MOVE "same" TO TL-EXPECTED
     MOVE "differ" TO TL-OBSERVED
     COMPUTE WS-N = DM-HEIGHT(WS-DIM) / 16 * 64
     IF CE-BIOMES(1:WS-N) = WS-SAVED(1:WS-N)
         MOVE "same" TO TL-OBSERVED
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL CE-BIOMES(WS-I:1) NOT = WS-SAVED(WS-I:1)
             CONTINUE
         END-PERFORM
         MOVE WS-I TO WS-EDIT
         MOVE FUNCTION ORD(CE-BIOMES(WS-I:1)) TO WS-N
         STRING "differ at " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED
         MOVE FUNCTION ORD(WS-SAVED(WS-I:1)) TO WS-N
         MOVE WS-N TO WS-EDIT
         STRING "same " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE FUNCTION ORD(CE-BIOMES(WS-I:1)) TO WS-N
         MOVE WS-N TO WS-EDIT
         STRING FUNCTION TRIM(TL-OBSERVED) " got " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CHUNK-BIOMES-REAL.

 COPY CORETEST.
