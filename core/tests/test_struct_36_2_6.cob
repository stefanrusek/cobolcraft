*> Acceptance test of docs/protocol/36-structures-2 section 6 (TemplateStructurePiece) in the pieces model: a template piece keeps its template, position, rotation, pivot and box (6.1),
*> STRUCT-PLACE-START gives it the start's pivot (36-1 8), post-processing places the template through the chunk's write box with flags 2 (6.2 steps 1 to 3), calls handleDataMarker for
*> each structure block in DATA mode inside the box (step 4: igloo and shipwreck markers set a loot table and draw one seed) and replaces each jigsaw marker by its final_state text,
*> air when the text does not parse (step 5). Runs over the standard content set of the generated packs (skipped as a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTTPL.
 COPY STRUCTPIECE.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-LABEL               PIC X(150).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Q1                  BINARY-LONG VALUE 0.
 01 WS-Q2                  BINARY-LONG VALUE 0.
 01 WS-Q3                  BINARY-LONG VALUE 0.
 01 WS-Q4                  BINARY-LONG VALUE 0.
 01 WS-Q5                  BINARY-LONG VALUE 0.
 01 WS-Q6                  BINARY-LONG VALUE 0.
 01 WS-Q7                  BINARY-LONG VALUE 0.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                 PIC -(18)9.
 01 WS-ED3                 PIC -(8)9.
 01 WS-ED4                 PIC -(8)9.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-S3                  BINARY-DOUBLE.
 01 WS-S4                  BINARY-DOUBLE.
 01 WS-LABEL-TAIL          PIC X(200).
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-2§6 TemplateStructurePiece: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE "T" TO TL-MODE

     MOVE "test:marker" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW

*>   6.1: the piece's box is getBoundingBox; an absent or unloaded template makes no piece.
     CALL "SPB-RESET"
     MOVE 0 TO WS-KIND
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     MOVE 0 TO WS-ROT
     PERFORM ADD-PIECE
     MOVE "the piece box of a 3 x 2 x 1 template at (4, 70, 4) is x 4..6, y 70..71, z 4..4" TO WS-LABEL
     PERFORM SHOW-BOX
     MOVE "4 70 4 6 71 4" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "a piece of SP-TYPE 100 keeps the template row and its kind" TO WS-LABEL
     MOVE SP-TYPE(WS-PIECE) TO WS-ED
     MOVE SP-T-ROW(WS-PIECE) TO WS-ED2
     MOVE WS-ROW TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "100 " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:no_such_template" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE WS-ROW TO WS-X
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-X WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-Q1 WS-Q2 WS-Q3 WS-Q4 WS-Q5 WS-Q6 WS-PIECE
     MOVE "an absent template makes no piece" TO WS-LABEL
     MOVE WS-PIECE TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-X
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-X WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-Q1 WS-Q2 WS-Q3 WS-Q4 WS-Q5 WS-Q6 WS-PIECE
     MOVE "row 0 makes no piece" TO WS-LABEL
     MOVE WS-PIECE TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   a full builder makes no piece either, and counts the lost one
     MOVE "test:marker" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-X
     CALL "SPB-RESET"
     MOVE SP-MAX TO SP-COUNT
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-X WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-Q1 WS-Q2 WS-Q3 WS-Q4 WS-Q5 WS-Q6 WS-PIECE
     MOVE "a full builder makes no piece and counts the lost one" TO WS-LABEL
     MOVE WS-PIECE TO WS-ED
     MOVE SP-LOST TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Kind 0 at (4, 70, 4): the chests draw a seed each, the markers do nothing; the jigsaws turn into their final_state.
     MOVE "test:marker" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     PERFORM RESET-RANDOM
     CALL "SPB-RESET"
     MOVE 0 TO WS-KIND
     MOVE 0 TO WS-ROT
     PERFORM ADD-PIECE
     PERFORM RUN-PIECES
     MOVE "kind 0: no request, the two chests drew two seeds (the next draw is the third)" TO WS-LABEL
     CALL "MSP-RNG-LONG" USING WS-S4
     MOVE GBL-COUNT TO WS-ED
     MOVE WS-S4 TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S3 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "0 " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the start's pivot is the box centre x, the min y and the centre z" TO WS-LABEL
     MOVE SP-PIV-X TO WS-ED
     MOVE SP-PIV-Y TO WS-ED2
     MOVE SP-PIV-Z TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 70 4" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 6 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM STATE-KEY
     MOVE "a jigsaw is replaced by its final_state" TO WS-LABEL
     MOVE "stone" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 71 TO WS-Y
     PERFORM STATE-KEY
     MOVE "a jigsaw with a final_state that does not parse becomes air" TO WS-LABEL
     MOVE "air" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     PERFORM STATE-KEY
     MOVE "the template's chest is placed" TO WS-LABEL
     MOVE "chest" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Shipwreck markers: a treasure_chest marker above a chest gives it its table and a third seed.
     PERFORM CLEAR-CHUNK
     PERFORM RESET-RANDOM
     CALL "SPB-RESET"
     MOVE 2 TO WS-KIND
     PERFORM ADD-PIECE
     PERFORM RUN-PIECES
     MOVE "kind 2: the marker above the chest at (4, 70, 4) requests the treasure table with the third seed" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE GBL-X(1) TO WS-ED3
     MOVE GBL-SEED(1) TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(GBL-LOOT(1)) " " FUNCTION TRIM(WS-ED2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S3 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "1 4 minecraft:chests/shipwreck_treasure " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Igloo markers, rotated a quarter turn: the "chest" marker turns to air and the chest below gets the igloo table.
     PERFORM CLEAR-CHUNK
     PERFORM RESET-RANDOM
     CALL "SPB-RESET"
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-ROT
     MOVE 8 TO WS-OX
     MOVE 8 TO WS-OZ
     PERFORM ADD-PIECE
     PERFORM RUN-PIECES
     MOVE "kind 1, rotated: the chest marker (1, 1, 0) is at (8, 71, 9) and the chest below it asks for the igloo table" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE GBL-X(1) TO WS-ED3
     MOVE GBL-Z(1) TO WS-ED4
     MOVE GBL-SEED(1) TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED3) "," FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(GBL-LOOT(1)) " " FUNCTION TRIM(WS-ED2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S3 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "1 8,9 minecraft:chests/igloo_chest " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 8 TO WS-X
     MOVE 71 TO WS-Y
     MOVE 9 TO WS-Z
     PERFORM STATE-KEY
     MOVE "kind 1: the chest marker position was set to air" TO WS-LABEL
     MOVE "air" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The write box clips the markers and the draws: only the column x = 4 is inside.
     PERFORM CLEAR-CHUNK
     PERFORM RESET-RANDOM
     CALL "SPB-RESET"
     MOVE 2 TO WS-KIND
     MOVE 0 TO WS-ROT
     MOVE 4 TO WS-OX
     MOVE 4 TO WS-OZ
     PERFORM ADD-PIECE
     PERFORM OPEN-WINDOW
     MOVE 4 TO SW-X1
     CALL "STRUCT-PLACE-START"
     MOVE "box: the first chest's seed, then the marker's (the second seed), one request" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE GBL-SEED(1) TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S2 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "1 " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   A marker above something that is not a chest does nothing; a template that places nothing has no markers handled.
     MOVE "test:markerstone" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     PERFORM CLEAR-CHUNK
     PERFORM RESET-RANDOM
     CALL "SPB-RESET"
     PERFORM ADD-PIECE
     PERFORM RUN-PIECES
     MOVE "a marker above a stone block makes no request and no draw" TO WS-LABEL
     CALL "MSP-RNG-LONG" USING WS-S4
     MOVE GBL-COUNT TO WS-ED
     MOVE WS-S4 TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S1 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "0 " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:nothing" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     PERFORM CLEAR-CHUNK
     CALL "SPB-RESET"
     PERFORM ADD-PIECE
     MOVE 0 TO GBL-COUNT
     PERFORM RUN-PIECES
     MOVE "a template with no blocks places nothing: the piece stops there" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     GOBACK.

 ADD-PIECE.
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-Q1 WS-Q2 WS-Q3 WS-Q4 WS-Q5 WS-Q6 WS-PIECE.

 OPEN-WINDOW.
     CALL "MSP-OPEN".

 RUN-PIECES.
     PERFORM OPEN-WINDOW
     CALL "STRUCT-PLACE-START".

*> RESET-RANDOM: the piece random at a known state, with the first draws S1, S2, S3 of that state recorded; GBL empty.
 RESET-RANDOM.
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-RNG-LONG" USING WS-S1
     CALL "MSP-RNG-LONG" USING WS-S2
     CALL "MSP-RNG-LONG" USING WS-S3
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI.

 CLEAR-CHUNK.
     MOVE LOW-VALUES TO CE-STATES
     MOVE 0 TO FL-DISCARDED
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     MOVE 0 TO WS-ROT.

 SHOW-BOX.
     MOVE SP-X0(WS-PIECE) TO WS-ED
     MOVE SP-Y0(WS-PIECE) TO WS-ED2
     MOVE SP-Z0(WS-PIECE) TO WS-ED3
     MOVE SP-X1(WS-PIECE) TO WS-ED4
     MOVE SPACES TO WS-LABEL-TAIL
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " " DELIMITED BY SIZE
         INTO WS-LABEL-TAIL
     MOVE SP-Y1(WS-PIECE) TO WS-ED
     MOVE SP-Z1(WS-PIECE) TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-LABEL-TAIL) " " FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED.

*> STATE-KEY: TL-OBSERVED is the block key at (WS-X, WS-Y, WS-Z).
 STATE-KEY.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE CB-KEY(WS-BLOCK + 1) TO TL-OBSERVED.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-2§6 TemplateStructurePiece: " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
