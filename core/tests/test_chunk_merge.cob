*> Implementation test (vanfmt lane; docs/protocol/07 section 10.7 "what must be preserved"): in a world of the 26.3 layout
*> (CW-LAYOUT 1) a chunk that is saved again keeps the keys of the chunk as the region file holds it that the core does not
*> model (InhabitedTime, structures, block and fluid ticks, any other key), while the keys it owns are rewritten and
*> isLightOn is dropped (the core writes no light arrays). In the CobolCraft layout nothing is merged.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-MERGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 4.
 01 WS-CZ                  BINARY-LONG VALUE 5.
 01 WS-ROW                 BINARY-LONG.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-ONE                 PIC X(8192).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE VALUE 999.
 01 WS-INT                 BINARY-LONG VALUE 5.
 01 WS-ONE-BYTE            BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE DIM-MAIN TO WS-DIM
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "PERSIST-DIRS"
*>   The region file holds a chunk with keys of a game that the core does not model.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "InhabitedTime" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "isLightOn" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE-BYTE
     MOVE "unknown_key" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:village" TO WN MOVE 17 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-DIM-DIR" USING WS-DIM WS-REGION WS-DIR WS-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME

*>   Layout 1: the save merges.
     MOVE 1 TO CW-LAYOUT
     CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
     PERFORM READ-BACK
     MOVE SPACES TO WS-OBSERVED
     MOVE "InhabitedTime" TO WS-PATH PERFORM ADD-GET
     MOVE "unknown_key" TO WS-PATH PERFORM ADD-GET
     MOVE "structures" TO WS-PATH PERFORM ADD-GET
     MOVE "isLightOn" TO WS-PATH PERFORM ADD-GET
     MOVE "xPos" TO WS-PATH PERFORM ADD-GET
     MOVE "sections[0].Y" TO WS-PATH PERFORM ADD-GET
     MOVE "test chunk merge in the 26.3 layout a saved chunk keeps InhabitedTime, structures and unknown keys, drops isLightOn, rewrites its own keys" TO TL-CASE
     MOVE "999 5 {starts:{minecraft:village:{}}} absent 4 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Layout 1 with no chunk in the file (a new chunk): the defaults of the CobolCraft writer.
     MOVE "rm -rf build/core-test-world/dimensions/cobolcraft/main/region" TO WS-ONE
     CALL "SYSTEM" USING WS-ONE
     CALL "PERSIST-DIRS"
     CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
     PERFORM READ-BACK
     MOVE SPACES TO WS-OBSERVED
     MOVE "InhabitedTime" TO WS-PATH PERFORM ADD-GET
     MOVE "structures" TO WS-PATH PERFORM ADD-GET
     MOVE "unknown_key" TO WS-PATH PERFORM ADD-GET
     MOVE "test chunk merge in the 26.3 layout a chunk new to the file has the default keys" TO TL-CASE
     MOVE "0 {starts:{},References:{}} absent" TO TL-EXPECTED
     PERFORM CHECK

*>   Layout 0: nothing is merged (the file of before is replaced).
     MOVE 0 TO CW-LAYOUT
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "unknown_key" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "REGION-WRITE" USING WS-DIR WS-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
     PERFORM READ-BACK
     MOVE SPACES TO WS-OBSERVED
     MOVE "unknown_key" TO WS-PATH PERFORM ADD-GET
     MOVE "test chunk merge in the CobolCraft layout the old file's keys are not kept" TO TL-CASE
     MOVE "absent" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 READ-BACK.
     CALL "PERSIST-DIM-DIR" USING WS-DIM WS-REGION WS-DIR WS-LENGTH
     CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CHUNK-MERGE.

 COPY CORETEST.
