*> Implementation test of the sky light of cells that let light through (lane bugblack; docs/protocol/32-light-engine.md section 5.2 and 24 part 2 section 5.3: sky light passes
*> through a block with dampening 0, and a block of dampening 1 takes one level). A standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default
*> /tmp/cc-test/generated; skipped as a pass without it): the chunks around the origin are generated and lit, and each column is walked from its topmost block down while nothing above
*> the cell blocks light. A cell holding a plant (short grass, flowers, ferns) or a dirt path reads the open sky, 15; the topmost leaf cell reads 14 and the air under it 13; the topmost
*> water cell reads 14. The stand-in used to store 0 at and below the topmost non-air block whatever it was, so the cells of plants and paths read 0 and the grass faces that look into
*> them rendered at the 0.1 floor (the black squares of the try14 screenshots). The counts of cells checked and wrong are displayed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-PLANTS.
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
 01 WS-CX                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-PUT                 BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-OPEN                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 24 TIMES.
 01 WS-KINDS.
    05 WS-ID-KIND          BINARY-LONG OCCURS 24 TIMES.
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:short_grass".
    05 FILLER              PIC X(40) VALUE "minecraft:fern".
    05 FILLER              PIC X(40) VALUE "minecraft:dandelion".
    05 FILLER              PIC X(40) VALUE "minecraft:poppy".
    05 FILLER              PIC X(40) VALUE "minecraft:azure_bluet".
    05 FILLER              PIC X(40) VALUE "minecraft:oxeye_daisy".
    05 FILLER              PIC X(40) VALUE "minecraft:cornflower".
    05 FILLER              PIC X(40) VALUE "minecraft:tall_grass".
    05 FILLER              PIC X(40) VALUE "minecraft:large_fern".
    05 FILLER              PIC X(40) VALUE "minecraft:dirt_path".
    05 FILLER              PIC X(40) VALUE "minecraft:oak_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:birch_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:spruce_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:jungle_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:acacia_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:dark_oak_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:water".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 17 TIMES.
 01 WS-TOTALS.
    05 WS-CHECKED          BINARY-LONG OCCURS 5 TIMES.
    05 WS-WRONG            BINARY-LONG OCCURS 5 TIMES.
 01 WS-EDIT                PIC -(9)9.
 01 WS-LINE                PIC X(120).
 01 WS-D1                  PIC 9.
 01 WS-FIXED               BINARY-LONG VALUE 0.
 01 WS-DEEP                BINARY-LONG.
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
         MOVE "test light plants no generated packs here, skipped" TO TL-CASE
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
     MOVE "PlantLight" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
*>   The block ids by name; kind 1 plant, 2 dirt path, 3 leaves, 4 water.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         MOVE WS-NAME(WS-I) TO WS-KEY
         CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID(WS-I)
         EVALUATE TRUE
             WHEN WS-I <= 9 MOVE 1 TO WS-ID-KIND(WS-I)
             WHEN WS-I = 10 MOVE 2 TO WS-ID-KIND(WS-I)
             WHEN WS-I <= 16 MOVE 3 TO WS-ID-KIND(WS-I)
             WHEN OTHER MOVE 4 TO WS-ID-KIND(WS-I)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO WS-CHECKED(WS-I) WS-WRONG(WS-I)
     END-PERFORM
     COMPUTE WS-SX = FUNCTION INTEGER(CW-SPAWN-X / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(CW-SPAWN-Z / 16)
     DISPLAY "light-plants spawn chunk " WS-SX " " WS-SZ
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_LIGHT_PLANTS_HALF"
     MOVE 0 TO WS-HALF
     IF WS-ENV NOT = SPACES
         COMPUTE WS-HALF = FUNCTION NUMVAL(WS-ENV)
     END-IF
     COMPUTE WS-CX0 = WS-SX - WS-HALF
     COMPUTE WS-CZ0 = WS-SZ - WS-HALF
     PERFORM VARYING WS-CZ FROM WS-CZ0 BY 1 UNTIL WS-CZ > WS-SZ + WS-HALF
         PERFORM VARYING WS-CX FROM WS-CX0 BY 1 UNTIL WS-CX > WS-SX + WS-HALF
             CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
             PERFORM CHECK-CHUNK
         END-PERFORM
     END-PERFORM
     MOVE WS-FIXED TO WS-EDIT
     DISPLAY "light-plants cells at or below a column top (0 before) that now read light: " FUNCTION TRIM(WS-EDIT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-CHECKED(WS-I) TO WS-EDIT
         MOVE SPACES TO WS-LINE
         MOVE WS-I TO WS-D1
         STRING "light-plants kind " WS-D1 " checked " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         MOVE WS-WRONG(WS-I) TO WS-EDIT
         STRING FUNCTION TRIM(WS-LINE) " wrong " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         DISPLAY FUNCTION TRIM(WS-LINE)
     END-PERFORM

     MOVE "test light plants the sample holds plants and water" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF WS-CHECKED(1) + WS-CHECKED(5) = 0
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants a generated cell holding a plant reads the open sky 15" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants a generated path cell under open sky reads 15" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants a generated topmost leaf cell reads 14 (15 less its dampening 1)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants a generated air cell under the topmost leaf cell reads 13" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants a generated topmost water cell reads 14" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Built cells above the highest block of the spawn chunk, each in a column of its own (the block change relights the chunk).
     MOVE WS-SX TO WS-CX
     MOVE WS-SZ TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-SX WS-SZ WS-ROW
     CALL "WORLD-COLUMN-TOPS" USING WS-ROW WS-TOPS
     MOVE 0 TO WS-HIGH
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         IF WS-TOP(WS-C) > WS-HIGH
             MOVE WS-TOP(WS-C) TO WS-HIGH
         END-IF
     END-PERFORM
     COMPUTE WS-WY = WS-HIGH + DM-MIN-Y(WS-DIM) + 6
     COMPUTE WS-WZ = WS-SZ * 16 + 2
*>   Column x + 1: a short grass; x + 3: a dirt path; x + 5: leaves (and the air below); x + 7: two leaves; x + 9: water.
     COMPUTE WS-WX = WS-SX * 16 + 1
     MOVE 1 TO WS-I
     PERFORM PUT-BLOCK
     MOVE "test light plants a built short grass cell in open sky reads 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE 0 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-WX = WS-SX * 16 + 3
     MOVE 10 TO WS-I
     PERFORM PUT-BLOCK
     MOVE "test light plants a built dirt path cell in open sky reads 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE 0 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants the air under a built dirt path reads 0 (the path occludes its underside)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE -1 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-WX = WS-SX * 16 + 5
     MOVE 11 TO WS-I
     PERFORM PUT-BLOCK
     MOVE "test light plants a built leaf cell in open sky reads 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE 0 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants the air cell under a built leaf reads 13" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE -1 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light plants the second air cell under a built leaf reads 12" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE -2 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-WX = WS-SX * 16 + 7
     MOVE 12 TO WS-I
     PERFORM PUT-BLOCK
     COMPUTE WS-WY = WS-WY - 1
     PERFORM PUT-BLOCK
     COMPUTE WS-WY = WS-WY + 1
     MOVE "test light plants a leaf under a leaf reads 13" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE -1 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-WX = WS-SX * 16 + 9
     MOVE 17 TO WS-I
     PERFORM PUT-BLOCK
     MOVE "test light plants a built water cell in open sky reads 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE 0 TO WS-N
     PERFORM GET-SKY
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Chunk WS-CX, WS-CZ in row WS-ROW: every column from its topmost block down while open.
 CHECK-CHUNK.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "WORLD-COLUMN-TOPS" USING WS-ROW WS-TOPS
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         PERFORM VARYING WS-Y FROM WS-TOP(WS-C) BY -1 UNTIL WS-Y < 0
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             PERFORM READ-SKY
             IF WS-LEVEL > 0
                 ADD 1 TO WS-FIXED
             END-IF
         END-PERFORM
         MOVE 1 TO WS-OPEN
         PERFORM VARYING WS-Y FROM WS-TOP(WS-C) BY -1 UNTIL WS-Y < 0 OR WS-OPEN = 0
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             MOVE 0 TO WS-KIND
             IF WS-STATE > 0
                 MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
                     IF WS-ID(WS-I) = WS-BLOCK
                         MOVE WS-ID-KIND(WS-I) TO WS-KIND
                     END-IF
                 END-PERFORM
                 IF WS-KIND = 0
                     MOVE 0 TO WS-OPEN
                 END-IF
             END-IF
             IF WS-KIND > 0
                 PERFORM READ-SKY
                 IF WS-KIND < 4
                     ADD 1 TO WS-CHECKED(WS-KIND)
                 ELSE
                     ADD 1 TO WS-CHECKED(5)
                 END-IF
                 EVALUATE WS-KIND
                     WHEN 1
                         IF WS-LEVEL NOT = 15
                             ADD 1 TO WS-WRONG(1)
                         END-IF
                     WHEN 2
                         IF WS-LEVEL NOT = 15
                             ADD 1 TO WS-WRONG(2)
                         END-IF
                         MOVE 0 TO WS-OPEN
                     WHEN 3
                         IF WS-LEVEL NOT = 14
                             ADD 1 TO WS-WRONG(3)
                         END-IF
                         PERFORM CHECK-BELOW
                         MOVE 0 TO WS-OPEN
                     WHEN OTHER
                         IF WS-LEVEL NOT = 14
                             ADD 1 TO WS-WRONG(5)
                         END-IF
                         MOVE 0 TO WS-OPEN
                 END-EVALUATE
             END-IF
         END-PERFORM
     END-PERFORM.

*> The stored sky light of cell WS-CELL into WS-LEVEL.
 READ-SKY.
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE WS-LEVEL = FUNCTION MOD(CE-SKY(WS-BYTE), 16)
     ELSE
         COMPUTE WS-LEVEL = CE-SKY(WS-BYTE) / 16
     END-IF.

*> The cell under the leaf cell WS-CELL, when it is air (state 0): the air under the topmost leaf reads 13.
 CHECK-BELOW.
     IF WS-Y > 0
         COMPUTE WS-BELOW = WS-CELL - 256
         IF CE-STATE(WS-BELOW) = 0
             MOVE WS-CELL TO WS-N
             MOVE WS-BELOW TO WS-CELL
             PERFORM READ-SKY
             MOVE WS-N TO WS-CELL
             ADD 1 TO WS-CHECKED(4)
             IF WS-LEVEL NOT = 13
                 ADD 1 TO WS-WRONG(4)
             END-IF
         END-IF
     END-IF.

*> Puts the default state of block WS-ID(WS-I) at WS-WX, WS-WY, WS-WZ.
 PUT-BLOCK.
     COMPUTE WS-PUT = CB-DEFAULT-STATE(WS-ID(WS-I) + 1)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT.

*> The stored sky light of the cell WS-N above (negative: below) WS-WX, WS-WY, WS-WZ into WS-GOT.
 GET-SKY.
     COMPUTE WS-CX = (WS-WX - FUNCTION MOD(WS-WX, 16)) / 16
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (WS-WY + WS-N - DM-MIN-Y(WS-DIM)) * 256 + (WS-WZ - WS-CZ * 16) * 16
         + WS-WX - WS-CX * 16 + 1
     PERFORM READ-SKY
     MOVE WS-LEVEL TO WS-GOT.
 END PROGRAM TEST-LIGHT-PLANTS.

 COPY CORETEST.
