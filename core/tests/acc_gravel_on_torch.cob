*> Acceptance test (CC-0046, operator report of try8: "placing gravel directly above a placed torch did not place the gravel"; docs/protocol/25 part 4 section 9.2 block item placement, 29b part 1 sections 3.1 and 4.3 falling blocks): a superflat world (CC_GENERATED_DIR; a pass without it).
*> A gravel stack in the hand is used on the top face of a standing torch (survival, through the real Use Item On packet): the gravel is placed in the cell above the torch, one item is used up, and the gravel then stays on the torch
*> through sixty ticks (the torch cell is not free, so it does not fall) while the torch stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GRAVEL-ON-TORCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-BEFORE              BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-KINDS.
    05 FILLER              PIC X(48) VALUE "torch".
    05 FILLER              PIC X(48) VALUE "wall_torch".
    05 FILLER              PIC X(160) VALUE SPACES.
    05 FILLER              PIC X(48) VALUE "soul_torch".
    05 FILLER              PIC X(48) VALUE "soul_wall_torch".
    05 FILLER              PIC X(160) VALUE SPACES.
    05 FILLER              PIC X(48) VALUE "redstone_torch".
    05 FILLER              PIC X(48) VALUE "redstone_wall_torch".
    05 FILLER              PIC X(160) VALUE "lit=true".
    05 FILLER              PIC X(48) VALUE "copper_torch".
    05 FILLER              PIC X(48) VALUE "copper_wall_torch".
    05 FILLER              PIC X(160) VALUE SPACES.
 01 WS-KIND-TABLE REDEFINES WS-KINDS.
    05 WS-KIND OCCURS 4 TIMES.
       10 WS-K-ITEM        PIC X(48).
       10 WS-K-WALL        PIC X(48).
       10 WS-K-EXTRA       PIC X(160).
 01 WS-LIGHTS.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 14.
 01 WS-LIGHT-TABLE REDEFINES WS-LIGHTS.
    05 WS-LIGHT            BINARY-LONG OCCURS 4 TIMES.
 01 WS-FACING-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
    05 FILLER              PIC X(5) VALUE "east ".
 01 WS-FACING-TABLE REDEFINES WS-FACING-NAMES.
    05 WS-FACING-NAME      PIC X(5) OCCURS 4 TIMES.
 01 WS-WANT                BINARY-LONG.
 01 WS-WKIND               BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-GRAVEL              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
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
         MOVE "acceptance torch standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Torch" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

     MOVE "gravel" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE "torch" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-TORCH
     MOVE "gravel" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-GRAVEL
     COMPUTE WS-X = WS-BX + 6
     COMPUTE WS-Z = WS-BZ + 6
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-TORCH
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-GRAVEL TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance gravel on torch: gravel used on the top of a standing torch is placed in the cell above it" TO WS-CASE
     PERFORM CHECK-N
     MOVE 4 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     MOVE "acceptance gravel on torch: the placement used up one gravel" TO WS-CASE
     PERFORM CHECK-N
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-GRAVEL TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance gravel on torch: the gravel rests on the torch after 60 ticks (the torch cell is not free)" TO WS-CASE
     PERFORM CHECK-N
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-TORCH TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "acceptance gravel on torch: the torch under the gravel stays" TO WS-CASE
     PERFORM CHECK-N

     STOP RUN.

*> WS-LX, WS-LZ: the cell the torch of case WS-I, WS-J went to (the clicked block WS-X, WS-Z moved one step in the direction of the face).
 TARGET-CELL.
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     EVALUATE WS-J
         WHEN 1
             SUBTRACT 1 FROM WS-LZ
         WHEN 2
             ADD 1 TO WS-LZ
         WHEN 3
             SUBTRACT 1 FROM WS-LX
         WHEN OTHER
             ADD 1 TO WS-LX
     END-EVALUATE.

*> WS-STATE: the default state of the block WS-KEY (a key without namespace in the generated set), 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-STATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-GRAVEL-ON-TORCH.
 COPY CORETEST.
 COPY CMDTEST.
