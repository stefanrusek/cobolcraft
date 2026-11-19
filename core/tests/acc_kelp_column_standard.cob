*> Acceptance test, lane bugkelpplace (operator report try18: "kelp doesn't visibly connect when placed": a column of placed kelp was a column of heads). 29b part 4 section 3.2: a kelp column
*> is one head (kelp, age 0 to 24 at placement) on top of bodies (kelp_plant): placing kelp on kelp turns the old head into a body through the shape update (step 7), the placement of kelp
*> with a kelp or a body above the cell gives a body (step 3), and removing the head turns the top body into a head (step 10). Standard world from the generated vanilla set
*> (CC_GENERATED_DIR; a skipped pass without it), kelp used four times upward through the real Use Item On handler; the Block Updates the client receives are read back too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-KELP-COLUMN-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-KELP                BINARY-LONG.
 01 WS-PLANT               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-TICKS               BINARY-LONG VALUE 40.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-UX                  BINARY-LONG.
 01 WS-UY                  BINARY-LONG.
 01 WS-UZ                  BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-TEXT                PIC X(32).
 01 WS-PROP                PIC X(24) VALUE "age".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-DROP                BINARY-LONG VALUE 0.
 01 WS-BLOCKS-TEXT         PIC X(1024).
 01 WS-PATTERN             PIC X(80).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance kelp column standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Kelpcolumn" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "kelp" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-KELP
     MOVE "kelp_plant" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-PLANT
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 IF WS-X > WS-BX AND WS-X < WS-BX + 11 AND WS-Z > WS-BZ AND WS-Z < WS-BZ + 11 AND WS-I <= 5
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-WATER
                 ELSE
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 6
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

*>   Four pieces upward on the floor of column 1: three bodies and one head.
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 2
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE WS-CX TO WS-UX
         MOVE WS-CZ TO WS-UZ
         COMPUTE WS-UY = WS-FLOOR + WS-K - 1
         CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-BLOCKS-TEXT
         PERFORM USE-KELP-AT
     END-PERFORM
     MOVE "kelp_plant" TO WS-WANT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE WS-CY = WS-FLOOR + WS-K
         MOVE WS-K TO WS-E1
         MOVE SPACES TO WS-CASE
         STRING "acceptance kelp column: piece " FUNCTION TRIM(WS-E1 LEADING) " of four is a kelp_plant" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-KEY
     END-PERFORM
     COMPUTE WS-CY = WS-FLOOR + 4
     MOVE "kelp" TO WS-WANT
     MOVE "acceptance kelp column: the top piece is a kelp head" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     COMPUTE WS-AGE = FUNCTION NUMVAL(WS-TEXT)
     MOVE 0 TO WS-OBSERVE
     IF WS-AGE >= 0 AND WS-AGE <= 24
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     MOVE "acceptance kelp column: the placed head has an age of 0 to 24" TO WS-CASE
     PERFORM CHECK-N
*>   The client was told: the Block Updates of the last placement hold the new head and the old head's change to a body.
     COMPUTE WS-E = WS-FLOOR + 3
     MOVE WS-PLANT TO WS-STATE
     PERFORM BLOCK-UPDATE-SEEN
     MOVE "acceptance kelp column: the client got a Block Update turning the old head into a kelp_plant" TO WS-CASE
     PERFORM CHECK-N
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "kelp_plant" TO WS-WANT
     COMPUTE WS-CY = WS-FLOOR + 3
     MOVE "acceptance kelp column: the body below the head is still a kelp_plant after the fluid updates" TO WS-CASE
     PERFORM CHECK-KEY
     MOVE "kelp" TO WS-WANT
     COMPUTE WS-CY = WS-FLOOR + 4
     MOVE "acceptance kelp column: the head is still a kelp after the fluid updates" TO WS-CASE
     PERFORM CHECK-KEY

*>   Removing the head: the top body becomes a head (step 10).
     CALL "LEVEL-DESTROY-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-DROP WS-BUDGET WS-RESULT
     MOVE "kelp" TO WS-WANT
     COMPUTE WS-CY = WS-FLOOR + 3
     MOVE "acceptance kelp column: with the head removed the top body becomes a kelp head" TO WS-CASE
     PERFORM CHECK-KEY
     MOVE "kelp_plant" TO WS-WANT
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "acceptance kelp column: the body under the new head stays a kelp_plant" TO WS-CASE
     PERFORM CHECK-KEY

*>   Kelp used in a cell that has a head above it: a body is placed (step 3).
     COMPUTE WS-CX = WS-BX + 5
     COMPUTE WS-CZ = WS-BZ + 2
     COMPUTE WS-CY = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-KELP
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     PERFORM USE-KELP-AT
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE "kelp_plant" TO WS-WANT
     MOVE "acceptance kelp column: kelp placed under a head is a kelp_plant" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "kelp" TO WS-WANT
     MOVE "acceptance kelp column: the head above stays a kelp" TO WS-CASE
     PERFORM CHECK-KEY
     STOP RUN.

*> WS-FOUND-STATE: the default state of the block WS-KEY, 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

*> The player holds kelp and uses it on the block WS-UX, WS-UY, WS-UZ (face up).
 USE-KELP-AT.
     MOVE "kelp" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-UX WS-UY WS-UZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-BLOCKS-TEXT.

*> WS-OBSERVE: 1 when the text of the last drain holds the Block Update "8(WS-CX,WS-E,WS-CZ=WS-STATE)".
 BLOCK-UPDATE-SEEN.
     MOVE WS-CX TO WS-E1
     MOVE WS-E TO WS-E2
     MOVE WS-CZ TO WS-E3
     MOVE WS-STATE TO WS-E4
     MOVE SPACES TO WS-PATTERN
     STRING "8(" FUNCTION TRIM(WS-E1 LEADING) "," FUNCTION TRIM(WS-E2 LEADING) "," FUNCTION TRIM(WS-E3 LEADING) "=" FUNCTION TRIM(WS-E4 LEADING) ")"
         DELIMITED BY SIZE INTO WS-PATTERN
     MOVE 0 TO WS-HITS
     INSPECT WS-BLOCKS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-PATTERN)
     MOVE 0 TO WS-OBSERVE
     IF WS-HITS > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT.

*> 1 when the block at WS-CX, WS-CY, WS-CZ has the key WS-WANT.
 CHECK-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-KELP-COLUMN-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
