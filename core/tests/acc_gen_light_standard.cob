*> Acceptance test, lane bugtorch (operator report: "Torches on walls don't give off any light, so the stronghold is completely dark"; docs/protocol/09 section 3.4 block light, 24 part 2 the light column
*> of wall_torch): a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). The start chunk of the nearest
*> stronghold and the eight chunks around it are generated and lit. The wall torches the stronghold's pieces wrote (and every other light source a generated chunk holds) are counted as light sources
*> of their chunk section (CK-SOURCES, which the light engine scans), so each wall torch lights its cell with 14. After the start chunk is saved, released and read back from its region file the
*> torches light it again (the loaded chunk counts its sources by reading, a generated one by scanning what the generator wrote).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-LIGHT-STANDARD.
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
 01 WS-CX0                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-EMITTING            BINARY-LONG.
 01 WS-COUNTED             BINARY-LONG.
 01 WS-BAD-CHUNKS          BINARY-LONG.
 01 WS-TORCHES             BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-WALL-ID             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-START-ROW           BINARY-LONG.
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
         MOVE "acceptance gen light standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "GenLight" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     MOVE "minecraft:wall_torch" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-WALL-ID
     MOVE "strongholds" TO WS-NAME
     MOVE 0 TO WS-OX WS-OY WS-OZ
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME CW-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-SX WS-SZ WS-LX WS-LY WS-LZ
     MOVE "acceptance gen light standard: the world has a stronghold ring chunk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF

*>   The start chunk first (its pieces overflow into the neighbours), then the eight around it.
     MOVE 0 TO WS-BAD-CHUNKS WS-TORCHES WS-DARK
     COMPUTE WS-CX0 = WS-SX - 1
     COMPUTE WS-CZ0 = WS-SZ - 1
     CALL "WORLD-CHUNK" USING WS-DIM WS-SX WS-SZ WS-ROW
     PERFORM VARYING WS-CZ FROM WS-CZ0 BY 1 UNTIL WS-CZ > WS-SZ + 1
         PERFORM VARYING WS-CX FROM WS-CX0 BY 1 UNTIL WS-CX > WS-SX + 1
             CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-CZ FROM WS-CZ0 BY 1 UNTIL WS-CZ > WS-SZ + 1
         PERFORM VARYING WS-CX FROM WS-CX0 BY 1 UNTIL WS-CX > WS-SX + 1
             PERFORM CHECK-CHUNK
         END-PERFORM
     END-PERFORM
     MOVE "acceptance gen light standard: the stronghold chunks hold wall torches" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TORCHES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen light standard: every chunk counts the light sources the generator wrote" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-CHUNKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen light standard: every generated wall torch lights its cell with at least 14" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DARK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The start chunk saved, released and read back from its region file: the torches light it again.
     CALL "WORLD-FIND" USING WS-DIM WS-SX WS-SZ WS-START-ROW
     CALL "PERSIST-CHUNK-SAVE" USING WS-START-ROW
     CALL "WORLD-CHUNK-RELEASE" USING WS-START-ROW
     MOVE 0 TO WS-BAD-CHUNKS WS-TORCHES WS-DARK
     CALL "WORLD-CHUNK" USING WS-DIM WS-SX WS-SZ WS-ROW
     MOVE WS-SX TO WS-CX
     MOVE WS-SZ TO WS-CZ
     PERFORM CHECK-CHUNK
     MOVE "acceptance gen light standard: the reloaded start chunk holds wall torches" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TORCHES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen light standard: the reloaded start chunk counts its light sources" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-CHUNKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen light standard: the reloaded wall torches light their cells with at least 14" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DARK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Chunk WS-CX, WS-CZ (loaded and lit): the emitting cells against the sum of CK-SOURCES (a difference adds one to WS-BAD-CHUNKS), the wall torches found (WS-TORCHES) and the ones
*> whose cell has a block light below 14 (WS-DARK).
 CHECK-CHUNK.
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELLS = DM-HEIGHT(WS-DIM) * 256
     MOVE 0 TO WS-EMITTING WS-COUNTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         IF CB-S-LIGHT(CE-STATE(WS-I) + 1) > 0
             ADD 1 TO WS-EMITTING
         END-IF
         IF CE-STATE(WS-I) > 0 AND CB-S-BLOCK(CE-STATE(WS-I) + 1) = WS-WALL-ID
             ADD 1 TO WS-TORCHES
             COMPUTE WS-Y = (WS-I - 1) / 256
             COMPUTE WS-REST = WS-I - 1 - WS-Y * 256
             COMPUTE WS-Z = WS-REST / 16
             COMPUTE WS-X = WS-REST - WS-Z * 16
             COMPUTE WS-X = WS-CX * 16 + WS-X
             COMPUTE WS-Z = WS-CZ * 16 + WS-Z
             COMPUTE WS-Y = WS-Y + DM-MIN-Y(WS-DIM)
             CALL "LIGHT-RAW" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
             IF WS-BLOCK-LIGHT < 14
                 ADD 1 TO WS-DARK
             END-IF
             SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         ADD CK-SOURCES(WS-ROW, WS-S) TO WS-COUNTED
     END-PERFORM
     IF WS-EMITTING NOT = WS-COUNTED
         ADD 1 TO WS-BAD-CHUNKS
     END-IF.
 END PROGRAM ACC-GEN-LIGHT-STANDARD.

 COPY NOSPAWN.
 COPY CORETEST.
