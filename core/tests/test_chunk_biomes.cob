*> Implementation test (vanfmt lane; docs/protocol/07 section 7.1, 7.2): the biome cells of a chunk are saved as they
*> are in memory and read back (before, the writer took one biome per column from the generator and the reader dropped
*> them, so a loaded standard chunk lost its biomes). Cells of one section hold up to nine different biomes, the
*> palette lists them in first-occurrence order of the entry index y * 16 + z * 4 + x, the data is 1, 2, 3 or 4 bits
*> wide by palette size (07 section 7.2 table), and a round trip gives every cell of every section back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-BIOMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 COPY PROTO.
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
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE DIM-MAIN TO WS-DIM
     MOVE 4 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
*>   Section 2: the cells 0 to 63 hold biome (index mod 3), so there are three entries; section 5: one biome;
*>   section 7: (index mod 2). The cobolcraft set holds only three biomes (CBI-COUNT), the 5 to 9 entry cases
*>   are in test_chunk_biomes_real.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 63
         COMPUTE WS-BASE = 2 * 64 + WS-I + 1
         MOVE FUNCTION MOD(WS-I, 3) TO CE-BIOME(WS-BASE)
         COMPUTE WS-BASE = 5 * 64 + WS-I + 1
         MOVE 1 TO CE-BIOME(WS-BASE)
         COMPUTE WS-BASE = 9 * 64 + WS-I + 1
         MOVE 99 TO CE-BIOME(WS-BASE)
         COMPUTE WS-BASE = 7 * 64 + WS-I + 1
         COMPUTE WS-N = WS-I / 4
         MOVE FUNCTION MOD(WS-N, 2) TO CE-BIOME(WS-BASE)
     END-PERFORM
     MOVE CE-BIOMES TO WS-SAVED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-NBT-WRITE" USING WS-ROW PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT

     MOVE "test chunk biomes section 2 holds three biomes in first-occurrence order, 2-bit data of 16 Longs" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "sections[2].biomes.palette" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "[" CBI-KEY(1)(1:CBI-KEY-LENGTH(1)) "," CBI-KEY(2)(1:CBI-KEY-LENGTH(2)) ","
         CBI-KEY(3)(1:CBI-KEY-LENGTH(3)) "]" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunk biomes section 2 data is L2 (64 entries at 2 bits is two Longs)" TO TL-CASE
     MOVE "sections[2].biomes.data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE "L2" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunk biomes section 5 is one biome without data, section 7 two biomes with 1-bit data" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "sections[5].biomes" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-OBSERVED) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "sections[7].biomes.data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-OBSERVED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "{palette:[" CBI-KEY(2)(1:CBI-KEY-LENGTH(2)) "]} L1" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunk biomes an id the table does not hold is written as biome 0" TO TL-CASE
     MOVE "sections[9].biomes.palette" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "[" CBI-KEY(1)(1:CBI-KEY-LENGTH(1)) "]" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         COMPUTE WS-BASE = 9 * 64 + WS-I
         MOVE 0 TO CE-BIOME(WS-BASE)
     END-PERFORM
     MOVE CE-BIOMES TO WS-SAVED

*>   Round trip: wipe the cells, read the chunk back.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE ALL X"09" TO CE-BIOMES
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE "test chunk biomes round trip: every biome cell of every section comes back" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF CE-BIOMES(1:1024) = WS-SAVED(1:1024)
         MOVE "same" TO TL-OBSERVED
     ELSE
         MOVE "differ" TO TL-OBSERVED
     END-IF
     MOVE "same" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CHUNK-BIOMES.

 COPY CORETEST.
