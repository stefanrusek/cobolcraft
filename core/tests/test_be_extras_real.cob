*> Real-data test (skipped as a pass without the generated packs; vanfmt lane; docs/protocol/07 section 10.7): a block entity of a type
*> the core knows keeps, in a world of the 26.3 layout, the keys of its saved compound that the core does not model: a chest
*> entry loaded with a key `future_key` writes it back beside the keys the core writes; the same entry loaded in the CobolCraft
*> layout does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-EXTRAS-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-ONE                 PIC X(8192).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ID-TEXT             PIC X(32) VALUE "minecraft:chest".
 01 WS-ID-LENGTH           BINARY-LONG VALUE 15.
 01 WS-X                   BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:chest".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 15.
 01 WS-RESULT              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
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
         MOVE "test be extras real no generated packs here, skipped" TO TL-CASE
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
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     MOVE CW-DIM(1) TO WS-DIM
     MOVE "T" TO TL-MODE
*>   Layout 0: the key is dropped.
     MOVE 0 TO CW-LAYOUT
     PERFORM LOAD-AND-SAVE
     MOVE SPACES TO WS-OBSERVED
     MOVE "block_entities[0].future_key" TO WS-PATH PERFORM ADD-GET
     MOVE "test be extras real in the CobolCraft layout the unmodelled key is not kept" TO TL-CASE
     MOVE "absent" TO TL-EXPECTED
     PERFORM CHECK
*>   Layout 1 (a second chest at x 5): the key stays.
     MOVE 1 TO CW-LAYOUT
     MOVE 5 TO WS-X
     PERFORM LOAD-AND-SAVE
     MOVE SPACES TO WS-OBSERVED
     MOVE "block_entities[1].future_key" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[1].id" TO WS-PATH PERFORM ADD-GET
     MOVE "test be extras real in the 26.3 layout a chest keeps its unmodelled key beside the keys the core writes" TO TL-CASE
     MOVE "7 minecraft:chest" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> A chest entry with future_key is loaded (BE-LOAD-CHUNK-ENTRY) and the chunk's block entities are written.
 LOAD-AND-SAVE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID-TEXT WS-ID-LENGTH
     MOVE "x" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-X
     MOVE "y" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-Y
     MOVE "z" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-Z
     MOVE "future_key" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-SEVEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-DIM WS-CX WS-CZ WS-KEY WS-KEY-LENGTH WS-RESULT WS-INDEX
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "BE-CHUNK-WRITE-MERGE" USING WS-DIM WS-CX WS-CZ PB-BUFFER WK-BUFFER WS-NONE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-EXTRAS-REAL.

 COPY CORETEST.
