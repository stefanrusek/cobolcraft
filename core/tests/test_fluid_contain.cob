*> Test of the blocks that hold water (core/src/fluids-contain.cob and the fluid cell of fluids-world-29a.cob, lane kelpfix; docs/protocol/29a section 5): on the generated vanilla data pack
*> (CC_GENERATED_DIR, skipped as a pass without it) FLUID-CONTAINER classes the water plants and the waterlogged-capable blocks, FLUID-OF-STATE gives a water source for kelp, seagrass and a
*> waterlogged block, and FLUID-CELL says that none of them accepts flowing water.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLUID-CONTAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CASE                PIC X(120).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
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
         MOVE "test fluid contain no generated packs here, skipped" TO TL-CASE
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
     MOVE "Contain" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60

*>   A state outside the table is no container
     MOVE -1 TO WS-STATE
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: a negative state is none" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     MOVE CB-STATE-COUNT TO WS-STATE
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: a state past the table is none" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     PERFORM CHECK-N

     MOVE "minecraft:stone" TO WS-KEY112
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: stone is none" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     PERFORM CHECK-N

     MOVE "minecraft:kelp" TO WS-KEY112
     PERFORM STATE-OF
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: kelp is a water plant that holds water" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     MOVE 11 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
     MOVE "fluid of state: kelp is the water source" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-FLUID * 100 + WS-KIND * 10 + WS-AMOUNT
     MOVE 128 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "FLUID-CELL" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     MOVE "fluid cell: flowing water is not accepted by kelp" TO WS-CASE
     MOVE WS-HOLDS TO WS-OBSERVE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     MOVE "minecraft:stone" TO WS-KEY112
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "FLUID-CELL" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     MOVE "fluid cell: stone holds no fluid" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-FLUID + WS-HOLDS
     PERFORM CHECK-N

     MOVE "minecraft:oak_slab" TO WS-KEY112
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     PERFORM STATE-OF
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: a dry slab is waterlogged-capable and holds nothing" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     MOVE 20 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
     MOVE "fluid of state: a dry slab has no fluid" TO WS-CASE
     MOVE WS-FLUID TO WS-OBSERVE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     PERFORM STATE-OF
     CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
     MOVE "fluid container: a waterlogged slab holds water" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-CLASS * 10 + WS-FULL
     MOVE 21 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
     MOVE "fluid of state: a waterlogged slab is the water source" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-FLUID * 100 + WS-KIND * 10 + WS-AMOUNT
     MOVE 128 TO WS-EXPECT
     PERFORM CHECK-N
     STOP RUN.

*> WS-STATE: the state of the block WS-KEY112 with the properties WS-PAIRS (default state for spaces).
 STATE-OF.
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FLUID-CONTAIN.
 COPY CORETEST.
 COPY CMDTEST.
