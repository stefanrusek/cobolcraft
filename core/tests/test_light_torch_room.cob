*> Implementation test, lane bugtorchblack (operator report of try15: "torches with a block above them render black"): a torch placed through Use Item On on the wall of a sealed stone room, in the
*> cell right under the ceiling, stores block light 14 at its own cell (sky 0: the room is sealed) and 13 in the cell beside it, and the Light Update packet of the chunk goes to the player. The core
*> side of the report: the client reads that light (client/tests/test_mesher_torch_light.cob). Generated standard content set (CC_GENERATED_DIR; skipped as a pass without it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-TORCH-ROOM.
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
         MOVE "test light torch room no generated packs here, skipped" TO TL-CASE
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
     MOVE "TorchRoom" TO CS-NEW-WORLD-NAME
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
*>   A sealed room: stone shell x, z in BX+3 .. BX+9, floor at WS-FLOOR, ceiling at WS-FLOOR + 4, air inside (three cells high).
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 MOVE WS-AIR TO WS-STATE
                 IF WS-I = 0 OR WS-I = 4
                     MOVE WS-STONE TO WS-STATE
                 END-IF
                 IF WS-I < 4 AND (WS-X = WS-BX + 3 OR WS-X = WS-BX + 9 OR WS-Z = WS-BZ + 3 OR WS-Z = WS-BZ + 9)
                     IF WS-X >= WS-BX + 3 AND WS-X <= WS-BX + 9 AND WS-Z >= WS-BZ + 3 AND WS-Z <= WS-BZ + 9
                         MOVE WS-STONE TO WS-STATE
                     END-IF
                 END-IF
                 IF WS-I = 4 AND (WS-X < WS-BX + 3 OR WS-X > WS-BX + 9 OR WS-Z < WS-BZ + 3 OR WS-Z > WS-BZ + 9)
                     MOVE WS-AIR TO WS-STATE
                 END-IF
                 IF WS-I = 5
                     MOVE WS-AIR TO WS-STATE
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 6.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA

*>   A torch clicked on the east face of the west wall block under the ceiling (cell BX+4, FLOOR+3, BZ+6).
     MOVE "torch" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     COMPUTE WS-X = WS-BX + 3
     COMPUTE WS-Z = WS-BZ + 6
     COMPUTE WS-Y = WS-FLOOR + 3
     MOVE 5 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     COMPUTE WS-LX = WS-BX + 4
     COMPUTE WS-LZ = WS-BZ + 6
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-LX WS-Y WS-LZ WS-STATE
     MOVE "wall_torch" TO WS-KEY
     MOVE "minecraft:wall_torch" TO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-E
     COMPUTE WS-EXPECT = WS-E
     COMPUTE WS-OBSERVE = CB-S-BLOCK(WS-STATE + 1)
     MOVE "test light torch room the torch went to the wall under the ceiling (a wall torch block)" TO WS-CASE
     PERFORM CHECK-N
     COMPUTE WS-E = WS-Y + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-LX WS-E WS-LZ WS-STATE
     MOVE WS-STONE TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     MOVE "test light torch room the cell above the torch is the stone ceiling" TO WS-CASE
     PERFORM CHECK-N
     CALL "LIGHT-RAW" USING WS-DIM WS-LX WS-Y WS-LZ WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 14 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "test light torch room the torch cell under the ceiling stores block light 14" TO WS-CASE
     PERFORM CHECK-N
     MOVE 0 TO WS-EXPECT
     MOVE WS-SKY TO WS-OBSERVE
     MOVE "test light torch room the sealed room stores sky light 0 at the torch cell" TO WS-CASE
     PERFORM CHECK-N
     COMPUTE WS-LX = WS-BX + 5
     CALL "LIGHT-RAW" USING WS-DIM WS-LX WS-Y WS-LZ WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 13 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "test light torch room the cell beside the torch stores block light 13" TO WS-CASE
     PERFORM CHECK-N
     COMPUTE WS-LX = WS-BX + 4
     COMPUTE WS-E = WS-Y - 1
     CALL "LIGHT-RAW" USING WS-DIM WS-LX WS-E WS-LZ WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 13 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "test light torch room the cell below the torch stores block light 13" TO WS-CASE
     PERFORM CHECK-N
*>   The player was sent the light of the chunk (a Light Update, id 49).
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA
     MOVE 0 TO WS-BEFORE
     INSPECT WS-TEXT-AREA TALLYING WS-BEFORE FOR ALL "49("
     MOVE 1 TO WS-EXPECT
     IF WS-BEFORE > 0
         MOVE 1 TO WS-OBSERVE
     ELSE
         MOVE 0 TO WS-OBSERVE
     END-IF
     MOVE "test light torch room the placement sent a Light Update to the player" TO WS-CASE
     PERFORM CHECK-N
     STOP RUN.

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
 END PROGRAM TEST-LIGHT-TORCH-ROOM.
 COPY CORETEST.
 COPY CMDTEST.
