*> Implementation test of the block light of cells that hold a partial block (lane bugstairlight; operator report of try19: "stairs render dark, the first real render issue I have seen this
*> run"). docs/protocol/32-light-engine.md section 5.1 (propagateIncrease: a cell takes level - opacity(state) from a lit neighbour, opacity = max(1, dampening)) and section 7 (a stair, a slab that is not
*> double, a path, farmland, snow, a carpet, a fence, a chest, a bed, a cauldron, a hopper and the like have dampening 0 or 1, never 15: light enters their cells; only a state whose occlusion shape is a full
*> block, 15, stops it). A sealed stone room of a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it), built above the
*> terrain, a torch (emission 14) in its middle and one partial block in each of 28 cells of the rings at Manhattan distance 3 and 4 from it: the cell of each reads 14 less its distance, the cell of a
*> double slab and of stone 0. The stand-in engine treated every state with a collision shape as opaque (CB-OPAQUE), so these cells read 0, and the faces of the client that look into them (the neighbours
*> of a stair, the stair's own treads and risers) were drawn at the 0.1 floor: black.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-PARTIAL.
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
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-BASE-Y              BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PUT                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-HITS                BINARY-LONG.
 01 WS-HITS2               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-WRONG               BINARY-LONG VALUE 0.
 01 WS-BAD-LIST            PIC X(300) VALUE SPACES.
 01 WS-PTR                 BINARY-LONG VALUE 1.
 01 WS-NUM                 PIC Z9.
 01 WS-NUM2                PIC Z9.
 01 WS-NAME                PIC X(24).
*> The 28 test blocks: key (24), the state wanted by its properties ("" = the default; the text must be found in the properties and "waterlogged=false" too), 1 when the cell must stay dark.
 01 WS-LIST.
    05 FILLER PIC X(24) VALUE "oak_stairs".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "oak_slab".
    05 FILLER PIC X(24) VALUE "type=bottom".
    05 FILLER PIC X(24) VALUE "oak_slab".
    05 FILLER PIC X(24) VALUE "type=top".
    05 FILLER PIC X(24) VALUE "farmland".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "dirt_path".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "snow".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "white_carpet".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "oak_trapdoor".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "cauldron".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "red_bed".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "chest".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "hopper".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "soul_sand".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "enchanting_table".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "anvil".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "lectern".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "stonecutter".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "daylight_detector".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "end_portal_frame".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "flower_pot".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "brewing_stand".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "oak_fence_gate".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "iron_bars".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "composter".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "oak_slab".
    05 FILLER PIC X(24) VALUE "type=double".
    05 FILLER PIC X(24) VALUE "stone".
    05 FILLER PIC X(24) VALUE SPACES.
 01 WS-LIST-TABLE REDEFINES WS-LIST.
    05 WS-ENTRY OCCURS 28 TIMES.
       10 WS-E-KEY         PIC X(24).
       10 WS-E-PROPS       PIC X(24).
*> The ring offsets (x, z) of the 28 cells: distance 3 (12 cells), then distance 4 (16 cells).
 01 WS-OFFSET-X.
    05 FILLER PIC X(28) VALUE "7144662255338044771155336622".
 01 WS-OFFSET-Z.
    05 FILLER PIC X(28) VALUE "4471535362624480535371716262".
 01 WS-OFF-X                BINARY-LONG OCCURS 28 TIMES.
 01 WS-OFF-Z                BINARY-LONG OCCURS 28 TIMES.
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
         MOVE "test light partial no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     PERFORM FILL-OFFSETS
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "PartialLight" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     COMPUTE WS-SX = FUNCTION INTEGER(CW-SPAWN-X / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(CW-SPAWN-Z / 16)
     CALL "WORLD-CHUNK" USING WS-DIM WS-SX WS-SZ WS-ROW
     CALL "WORLD-COLUMN-TOPS" USING WS-ROW WS-TOPS
     MOVE 0 TO WS-HIGH
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         IF WS-TOP(WS-C) > WS-HIGH
             MOVE WS-TOP(WS-C) TO WS-HIGH
         END-IF
     END-PERFORM
*>   The floor of the room (world y) lies above every block of the chunk; the shell is x, z 1 to 13 of the chunk, the torch at 7, 7.
     COMPUTE WS-BASE-Y = WS-HIGH + DM-MIN-Y(WS-DIM) + 8
     COMPUTE WS-X0 = WS-SX * 16
     COMPUTE WS-Z0 = WS-SZ * 16
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "minecraft:torch" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-TORCH
     CALL "LIGHT-BATCH-BEGIN"
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 13
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 13
             COMPUTE WS-WX = WS-X0 + WS-A
             COMPUTE WS-WZ = WS-Z0 + WS-B
             MOVE WS-BASE-Y TO WS-WY
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             ADD 3 TO WS-WY
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             IF WS-A = 1 OR WS-A = 13 OR WS-B = 1 OR WS-B = 13
                 COMPUTE WS-WY = WS-BASE-Y + 1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
                 ADD 1 TO WS-WY
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-WX = WS-X0 + 7
     COMPUTE WS-WZ = WS-Z0 + 7
     COMPUTE WS-WY = WS-BASE-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-TORCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         PERFORM PUT-TEST-BLOCK
     END-PERFORM
     CALL "LIGHT-BATCH-END"

*>   The torch's own cell and the air beside it hold the light of an open room (the baseline of the table).
     MOVE 0 TO WS-A WS-B
     MOVE 14 TO WS-EXPECT
     PERFORM READ-CELL
     MOVE "test light partial the torch of the sealed room lights its own cell with 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-WRONG
     MOVE 1 TO WS-PTR
     MOVE SPACES TO WS-BAD-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         MOVE WS-OFF-X(WS-I) TO WS-A
         MOVE WS-OFF-Z(WS-I) TO WS-B
         COMPUTE WS-DIST = FUNCTION ABS(WS-A) + FUNCTION ABS(WS-B)
         COMPUTE WS-EXPECT = 14 - WS-DIST
         IF WS-I >= 27
             MOVE 0 TO WS-EXPECT
         END-IF
         PERFORM READ-CELL
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-E-KEY(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
         DISPLAY "light-partial " FUNCTION TRIM(WS-E-KEY(WS-I)) " " FUNCTION TRIM(WS-E-PROPS(WS-I)) " distance " WS-DIST " block light " WS-LEVEL
             " expected " WS-EXPECT " (stand-in opaque flag of the block: " CB-OPAQUE(WS-ID + 1) ")"
         IF WS-LEVEL NOT = WS-EXPECT
             ADD 1 TO WS-WRONG
             IF WS-PTR < 270
                 STRING FUNCTION TRIM(WS-E-KEY(WS-I)) " " DELIMITED BY SIZE INTO WS-BAD-LIST WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "test light partial every partial block cell of the room reads 14 less its distance from the torch, a double slab and stone 0; wrong: "
         FUNCTION TRIM(WS-BAD-LIST) DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The ring offsets as numbers: each digit is the offset plus 4.
 FILL-OFFSETS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         COMPUTE WS-OFF-X(WS-I) = FUNCTION NUMVAL(WS-OFFSET-X(WS-I:1)) - 4
         COMPUTE WS-OFF-Z(WS-I) = FUNCTION NUMVAL(WS-OFFSET-Z(WS-I:1)) - 4
     END-PERFORM.

*> Puts test block WS-I (key, properties) in its cell of the room: the torch cell offset by WS-OFF-X(WS-I), WS-OFF-Z(WS-I).
 PUT-TEST-BLOCK.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-E-KEY(WS-I)) DELIMITED BY SIZE INTO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-PUT
     IF WS-E-PROPS(WS-I) NOT = SPACES
         PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-ID + 1) BY 1
                 UNTIL WS-S >= CB-FIRST-STATE(WS-ID + 1) + CB-STATES(WS-ID + 1)
             CALL "BLOCKS-STATE-PROPS" USING WS-S WS-PROPS
             MOVE 0 TO WS-HITS WS-HITS2
             INSPECT WS-PROPS TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-E-PROPS(WS-I))
             INSPECT WS-PROPS TALLYING WS-HITS2 FOR ALL "waterlogged=false"
             IF WS-HITS > 0 AND WS-HITS2 > 0
                 MOVE WS-S TO WS-PUT
             END-IF
         END-PERFORM
     END-IF
     COMPUTE WS-WX = WS-X0 + 7 + WS-OFF-X(WS-I)
     COMPUTE WS-WZ = WS-Z0 + 7 + WS-OFF-Z(WS-I)
     COMPUTE WS-WY = WS-BASE-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT.

*> The stored block light at the torch cell offset by WS-A, WS-B into WS-LEVEL.
 READ-CELL.
     COMPUTE WS-WX = WS-X0 + 7 + WS-A
     COMPUTE WS-WZ = WS-Z0 + 7 + WS-B
     COMPUTE WS-WY = WS-BASE-Y + 1
     COMPUTE WS-CX = (WS-WX - FUNCTION MOD(WS-WX, 16)) / 16
     COMPUTE WS-CZ = (WS-WZ - FUNCTION MOD(WS-WZ, 16)) / 16
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (WS-WY - DM-MIN-Y(WS-DIM)) * 256 + (WS-WZ - WS-CZ * 16) * 16 + WS-WX - WS-CX * 16 + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE WS-LEVEL = FUNCTION MOD(CE-BLOCK-LIGHT(WS-BYTE), 16)
     ELSE
         COMPUTE WS-LEVEL = CE-BLOCK-LIGHT(WS-BYTE) / 16
     END-IF.
 END PROGRAM TEST-LIGHT-PARTIAL.

 COPY CORETEST.
