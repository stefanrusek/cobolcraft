*> Acceptance test (wrap agent B round 6, T29571; docs/protocol/30-redstone-3-pistons.md section 7.6, 07 section 7.3): saving and loading a moving block entity. A moving piston block in the middle of its move is
*> saved with `blockState` (the key as a string for the default state of its block, else a compound {id, properties}), `facing` (byte), `progress` (float, the value of progressO), `extending` and `source`
*> (bytes) under the id minecraft:piston, and read back with the moved state, the direction, the flags and the progress (progress and progressO both); a missing or unknown block state is air and a facing
*> outside 0 to 5 wraps as abs(n rem 6). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-PISTON-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-SKIP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-FLAG-N              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-piston-save-world".
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 803.
 01 WS-Y                   BINARY-LONG VALUE 101.
 01 WS-Z                   BINARY-LONG VALUE 803.
 01 WS-CX                  BINARY-LONG VALUE 50.
 01 WS-CZ                  BINARY-LONG VALUE 50.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-MOVING              BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 324.
 01 WS-CLEAR-FLAGS         BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-DIRECTION           BINARY-LONG VALUE 5.
 01 WS-EXTENDING           BINARY-LONG VALUE 1.
 01 WS-SOURCE              BINARY-LONG VALUE 0.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-ONE                 PIC X(8192).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-BLOCKS-NAME         PIC X(32) VALUE "block_entities".
 01 WS-LIST-TYPE           BINARY-LONG.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:moving_piston".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 23.
 01 WS-ID-TEXT             PIC X(32) VALUE "minecraft:piston".
 01 WS-ID-LENGTH           BINARY-LONG VALUE 16.
 01 WS-BAD-KEY             PIC X(32) VALUE "minecraft:no_such_block".
 01 WS-BAD-LENGTH          BINARY-LONG VALUE 23.
 01 WS-BYTE                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-STATE-EDIT          PIC -(9)9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb piston save: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-INDEX

*>   A. a moving block with a non-default moved state (an upside down stair), extending east, at progress 0.5: the keys of the saved compound
     MOVE 4 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     CALL "PST-STATE-OF" USING WS-CODE WS-FACE-N WS-FLAG-N WS-TYPE-N WS-MOVING
     MOVE "oak_stairs" TO WS-K MOVE "facing=south,half=top,shape=straight,waterlogged=false" TO WS-PR PERFORM MAKE-STATE MOVE WS-ST TO WS-MOVED
     PERFORM PUT-MOVING
     MOVE 0.5 TO BE-PROGRESS-OLD(WS-INDEX)
     MOVE 1.0 TO BE-PROGRESS(WS-INDEX)
     PERFORM SAVE-CHUNK
     MOVE SPACES TO WS-OBSERVED
     MOVE "block_entities[0].id" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].blockState.id" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].blockState.properties.facing" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].blockState.properties.half" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].facing" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].progress" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].extending" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].source" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance wrapb piston save 30-3 7.6 a moving block is saved with blockState, facing, the progressO value, extending and source" TO TL-CASE
     MOVE "minecraft:piston minecraft:oak_stairs south top 5 0.500 1 0" TO TL-EXPECTED
     PERFORM CHECK

*>   B. the saved entry read back into a fresh block entity: the moved state, the direction, the flags and progress = progressO = 0.5
     MOVE 0 TO WS-ST
     PERFORM CLEAR-CELL
     PERFORM LOAD-SAVED
     PERFORM OBSERVE-BE
     MOVE "acceptance wrapb piston save 30-3 7.6 the saved entry loads: the moved state, direction 5, extending 1, source 0, progress and progressO 0.5 (500 thousandths)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-MOVED TO WS-STATE-EDIT
     STRING FUNCTION TRIM(WS-STATE-EDIT) " 5 1 0 500 500" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   C. a default moved state (a stone block) is saved as the plain key string and a source piston keeps its flags
     MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM MAKE-STATE MOVE WS-ST TO WS-MOVED
     MOVE 3 TO WS-DIRECTION MOVE 0 TO WS-EXTENDING MOVE 1 TO WS-SOURCE
     PERFORM CLEAR-CELL
     PERFORM PUT-MOVING
     MOVE 0.25 TO BE-PROGRESS-OLD(WS-INDEX)
     PERFORM SAVE-CHUNK
     MOVE SPACES TO WS-OBSERVED
     MOVE "block_entities[0].blockState" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].facing" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].extending" TO WS-PATH PERFORM ADD-GET
     MOVE "block_entities[0].source" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance wrapb piston save 30-3 7.6 a default moved state is saved as its key string, extending 0 and source 1 as bytes" TO TL-CASE
     MOVE "minecraft:stone 3 0 1" TO TL-EXPECTED
     PERFORM CHECK
     PERFORM CLEAR-CELL
     PERFORM LOAD-SAVED
     PERFORM OBSERVE-BE
     MOVE "acceptance wrapb piston save 30-3 7.6 and the string form loads" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-MOVED TO WS-STATE-EDIT
     STRING FUNCTION TRIM(WS-STATE-EDIT) " 3 0 1 250 250" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   D. an entry with an unknown block, a facing of -1 (abs(-1 rem 6) = 1), another of 9 (3) and no progress: air, the wrapped directions, progress 0
     PERFORM CLEAR-CELL
     MOVE -1 TO WS-BYTE
     PERFORM BUILD-ENTRY
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-DIM WS-CX WS-CZ WS-KEY WS-KEY-LENGTH WS-RESULT WS-INDEX
     PERFORM OBSERVE-BE
     MOVE "acceptance wrapb piston save 30-3 7.6 an unknown block loads as air and a facing of -1 wraps to 1, no progress is 0" TO TL-CASE
     MOVE "0 1 1 0 0 0" TO TL-EXPECTED
     PERFORM CHECK
     PERFORM CLEAR-CELL
     MOVE 9 TO WS-BYTE
     PERFORM BUILD-ENTRY
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-DIM WS-CX WS-CZ WS-KEY WS-KEY-LENGTH WS-RESULT WS-INDEX
     PERFORM OBSERVE-BE
     MOVE "acceptance wrapb piston save 30-3 7.6 a facing of 9 wraps to 3" TO TL-CASE
     MOVE "0 3 1 0 0 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 MAKE-STATE.
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-MOVING.
*>   the moving piston WS-MOVING at (WS-X, WS-Y, WS-Z) with the entity of the moved state WS-MOVED, direction WS-DIRECTION, extending WS-EXTENDING, source WS-SOURCE
     CALL "PST-PUT-MOVING" USING WS-DIM WS-X WS-Y WS-Z WS-MOVING WS-MOVED WS-DIRECTION WS-EXTENDING WS-SOURCE WS-FLAGS
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX.

 CLEAR-CELL.
*>   the cell is air and every block entity of it is gone, so that a load meets a new entity as a chunk read does
     MOVE 0 TO WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-CLEAR-FLAGS WS-BUDGET WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = WS-DIM AND BE-X(WS-I) = WS-X AND BE-Y(WS-I) = WS-Y AND BE-Z(WS-I) = WS-Z
             MOVE 0 TO BE-USED(WS-I)
         END-IF
     END-PERFORM.

 SAVE-CHUNK.
*>   the block entities of the chunk as a compound in PB-BUFFER, WS-ROOT its root payload
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "BE-CHUNK-WRITE-MERGE" USING WS-DIM WS-CX WS-CZ PB-BUFFER WK-BUFFER WS-NONE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.

 LOAD-SAVED.
*>   the first block entity of the saved list is read into a new entity: PB-POS goes to the first element's payload
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-LIST-TYPE WS-LIST-COUNT
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-DIM WS-CX WS-CZ WS-KEY WS-KEY-LENGTH WS-RESULT WS-INDEX.

 BUILD-ENTRY.
*>   a piston entry at (WS-X, WS-Y, WS-Z) with the block no_such_block, facing WS-BYTE, extending 1 and no progress or source
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
     MOVE "blockState" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-BAD-KEY WS-BAD-LENGTH
     MOVE "facing" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-BYTE
     MOVE "extending" TO WN MOVE 9 TO WL
     MOVE 1 TO WS-BYTE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-BYTE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE.

 OBSERVE-BE.
*>   WS-OBSERVED / TL-OBSERVED = "<moved state> <direction> <extending> <source> <progress> <progressO>" of the entity WS-INDEX
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     MOVE BE-XI(WS-INDEX, 1) TO WS-E1
     MOVE BE-XI(WS-INDEX, 2) TO WS-E2
     MOVE BE-XI(WS-INDEX, 3) TO WS-E3
     MOVE BE-XI(WS-INDEX, 4) TO WS-E4
     MOVE SPACES TO WS-OBSERVED
     MOVE BE-PROGRESS(WS-INDEX) TO WS-FLOAT
     MOVE FUNCTION INTEGER(WS-FLOAT * 1000 + 0.5) TO WS-E5
     MOVE BE-PROGRESS-OLD(WS-INDEX) TO WS-FLOAT
     MOVE FUNCTION INTEGER(WS-FLOAT * 1000 + 0.5) TO WS-E6
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-OBSERVED.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-WRAPB-PISTON-SAVE.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
