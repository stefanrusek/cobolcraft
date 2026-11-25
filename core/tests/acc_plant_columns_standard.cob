*> Acceptance test, lane bugupdateorder (operator report: "placing kelp in water works now, breaking kelp has the same update bug. They update based on neighbor not all at once"):
*> when a piece of a plant column is broken (or the ground under it goes), the pieces that depended on it follow, bottom to top, each with its drop, and the pieces below stay. A standard world
*> (CC_GENERATED_DIR; skipped as a pass without it) with a stone floor, the column built with the level, the break fed as Player Action (creative: at once), CORE-TICK one tick at a time.
*> Every case asserts the column right after the break (before any tick: the cascade runs within the tick of the break) and after three ticks (the water beside the cane's sand flows into the cell the sand left), and prints a TRACE line: the column right after the break and after each of the next ticks, one character per cell ('.' air, 'w' water, a digit the column cell that block matches).
*> Docs: 29b part 4 section 3.2 (the growing plant family: updateShape of a body or head SCHEDULES a block tick with delay 1 when its support is gone, the tick destroys it with drops; the top body
*> piece whose growth cell is no longer plant becomes a head), 4 (sugar cane), 6 (bamboo), 5 (cactus); 29 sections 3.2 and 13.2 (a shape update that returns air destroys at once).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PLANT-COLUMNS-STANDARD.
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
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-SPEC                PIC X(120).
 01 WS-SPEC-KEY            PIC X(48).
 01 WS-SPEC-PROPS          PIC X(120).
 01 WS-PAIR                PIC X(48).
 01 WS-PAIR-NAME           PIC X(24).
 01 WS-PAIR-VALUE          PIC X(32).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-BRACKET             BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-LABEL               PIC X(120).
 01 WS-TICKS               BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BREAK               BINARY-LONG.
 01 WS-SIDE-STONE          BINARY-LONG.
 01 WS-WANT                PIC X(9).
 01 WS-WANT3               PIC X(9).
 01 WS-WATER-FILL          BINARY-LONG.
 01 WS-SIDE-WATER          BINARY-LONG.
 01 WS-CELL-SPEC           PIC X(60) OCCURS 9 TIMES.
 01 WS-CELL-BLOCK          BINARY-LONG OCCURS 9 TIMES.
 01 WS-CELL-STATE          BINARY-LONG OCCURS 9 TIMES.
 01 WS-TRACE               PIC X(400).
 01 WS-TRACE-AT            BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DIGIT               PIC 99.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-WANT-TRACE          PIC X(80).
 01 WS-BLK                 BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "random_tick_speed".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
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
         MOVE "acceptance plant columns standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "PlantColumns" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE "stone" TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-STONE
     MOVE "water" TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-WATER
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PZ = WS-BZ + 5
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 3.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-PZ + 0.5
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

*>   Kelp in a pool: sand, four kelp_plant and a kelp head, water around and above.
     MOVE "kelp: break the middle piece" TO WS-LABEL
     MOVE "16wwwwwww" TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-KELP
     MOVE 3 TO WS-BREAK
     PERFORM RUN-COLUMN
     MOVE "kelp: break the bottom piece" TO WS-LABEL
     MOVE "1wwwwwwww" TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-KELP
     MOVE 2 TO WS-BREAK
     PERFORM RUN-COLUMN
     MOVE "kelp: break the sand under it" TO WS-LABEL
     MOVE ".wwwwwwww" TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-KELP
     MOVE 1 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Sugar cane: sand with water beside it, four canes.
     MOVE "sugar_cane: break the second cane" TO WS-LABEL
     MOVE "12......." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-CANE
     MOVE 3 TO WS-BREAK
     PERFORM RUN-COLUMN
     MOVE "sugar_cane: break the sand under it" TO WS-LABEL
     MOVE "........." TO WS-WANT
     MOVE "?........" TO WS-WANT3
     PERFORM SET-CANE
     MOVE 1 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Bamboo on dirt.
     MOVE "bamboo: break the second stalk" TO WS-LABEL
     MOVE "12......." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-BAMBOO
     MOVE 3 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Cactus on sand.
     MOVE "cactus: break the second piece" TO WS-LABEL
     MOVE "12......." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-CACTUS
     MOVE 3 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Weeping vines under a stone ceiling.
     MOVE "weeping_vines: break the middle piece" TO WS-LABEL
     MOVE "....26..." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-WEEPING
     MOVE 4 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Twisting vines on sand.
     MOVE "twisting_vines: break the middle piece" TO WS-LABEL
     MOVE "15......." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-TWISTING
     MOVE 3 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   Cave vines under a stone ceiling.
     MOVE "cave_vines: break the middle piece" TO WS-LABEL
     MOVE "....26..." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-CAVE
     MOVE 4 TO WS-BREAK
     PERFORM RUN-COLUMN
*>   A block placed beside an intact piece sends it a shape update, and the column stays as it is (no piece is destroyed or turned into a head).
     MOVE "weeping_vines: a block beside the middle piece changes nothing" TO WS-LABEL
     MOVE ".23336..." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-WEEPING
     MOVE 4 TO WS-SIDE-STONE
     MOVE 0 TO WS-BREAK
     PERFORM RUN-COLUMN
     MOVE "twisting_vines: a block beside the middle piece changes nothing" TO WS-LABEL
     MOVE "12225...." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-TWISTING
     MOVE 3 TO WS-SIDE-STONE
     MOVE 0 TO WS-BREAK
     PERFORM RUN-COLUMN
     MOVE "cave_vines: a block beside the middle piece changes nothing" TO WS-LABEL
     MOVE ".23336..." TO WS-WANT
     MOVE WS-WANT TO WS-WANT3
     PERFORM SET-CAVE
     MOVE 4 TO WS-SIDE-STONE
     MOVE 0 TO WS-BREAK
     PERFORM RUN-COLUMN
     STOP RUN.

 CLEAR-CELLS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         MOVE SPACES TO WS-CELL-SPEC(WS-K)
     END-PERFORM
     MOVE 0 TO WS-WATER-FILL WS-SIDE-WATER WS-SIDE-STONE.

 SET-KELP.
     PERFORM CLEAR-CELLS
     MOVE "sand" TO WS-CELL-SPEC(1)
     MOVE "kelp_plant" TO WS-CELL-SPEC(2)
     MOVE "kelp_plant" TO WS-CELL-SPEC(3)
     MOVE "kelp_plant" TO WS-CELL-SPEC(4)
     MOVE "kelp_plant" TO WS-CELL-SPEC(5)
     MOVE "kelp[age=5]" TO WS-CELL-SPEC(6)
     MOVE 1 TO WS-WATER-FILL.

 SET-CANE.
     PERFORM CLEAR-CELLS
     MOVE "sand" TO WS-CELL-SPEC(1)
     MOVE "sugar_cane" TO WS-CELL-SPEC(2)
     MOVE "sugar_cane" TO WS-CELL-SPEC(3)
     MOVE "sugar_cane" TO WS-CELL-SPEC(4)
     MOVE "sugar_cane" TO WS-CELL-SPEC(5)
     MOVE 1 TO WS-SIDE-WATER.

 SET-BAMBOO.
     PERFORM CLEAR-CELLS
     MOVE "dirt" TO WS-CELL-SPEC(1)
     MOVE "bamboo" TO WS-CELL-SPEC(2)
     MOVE "bamboo" TO WS-CELL-SPEC(3)
     MOVE "bamboo" TO WS-CELL-SPEC(4)
     MOVE "bamboo" TO WS-CELL-SPEC(5).

 SET-CACTUS.
     PERFORM CLEAR-CELLS
     MOVE "sand" TO WS-CELL-SPEC(1)
     MOVE "cactus" TO WS-CELL-SPEC(2)
     MOVE "cactus" TO WS-CELL-SPEC(3)
     MOVE "cactus" TO WS-CELL-SPEC(4)
     MOVE "cactus" TO WS-CELL-SPEC(5).

*> Weeping vines hang: the stone anchor is the TOP cell (7), then three bodies and the head at the bottom (cell 2).
 SET-WEEPING.
     PERFORM CLEAR-CELLS
     MOVE "weeping_vines" TO WS-CELL-SPEC(2)
     MOVE "weeping_vines_plant" TO WS-CELL-SPEC(3)
     MOVE "weeping_vines_plant" TO WS-CELL-SPEC(4)
     MOVE "weeping_vines_plant" TO WS-CELL-SPEC(5)
     MOVE "stone" TO WS-CELL-SPEC(6).

 SET-TWISTING.
     PERFORM CLEAR-CELLS
     MOVE "sand" TO WS-CELL-SPEC(1)
     MOVE "twisting_vines_plant" TO WS-CELL-SPEC(2)
     MOVE "twisting_vines_plant" TO WS-CELL-SPEC(3)
     MOVE "twisting_vines_plant" TO WS-CELL-SPEC(4)
     MOVE "twisting_vines" TO WS-CELL-SPEC(5).

 SET-CAVE.
     PERFORM CLEAR-CELLS
     MOVE "cave_vines" TO WS-CELL-SPEC(2)
     MOVE "cave_vines_plant" TO WS-CELL-SPEC(3)
     MOVE "cave_vines_plant" TO WS-CELL-SPEC(4)
     MOVE "cave_vines_plant" TO WS-CELL-SPEC(5)
     MOVE "stone" TO WS-CELL-SPEC(6).

*> Clears the volume, builds the cells of WS-CELL-SPEC at floor + 1 + (index - 1) in the column (a water pool around them when WS-WATER-FILL is 1, water beside the first cell when
*> WS-SIDE-WATER is 1), breaks cell WS-BREAK through Player Action (creative; none when 0), puts a stone beside cell WS-SIDE-STONE with the level's own change path (none when 0), and traces the column.
 RUN-COLUMN.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             PERFORM VARYING WS-DY FROM 1 BY 1 UNTIL WS-DY > 12
                 COMPUTE WS-X = WS-PX + WS-DX
                 COMPUTE WS-Y = WS-FLOOR + WS-DY
                 COMPUTE WS-Z = WS-PZ + WS-DZ
                 MOVE WS-AIR TO WS-STATE
                 IF WS-WATER-FILL = 1 AND WS-DY >= 2
                     MOVE WS-WATER TO WS-STATE
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-SIDE-WATER = 1
         COMPUTE WS-X = WS-PX + 1
         COMPUTE WS-Y = WS-FLOOR + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-PZ WS-WATER
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-CELL-BLOCK(WS-I) WS-CELL-STATE(WS-I)
         IF WS-CELL-SPEC(WS-I) NOT = SPACES
             MOVE WS-CELL-SPEC(WS-I) TO WS-SPEC
             PERFORM SPEC-STATE
             MOVE WS-STATE TO WS-CELL-STATE(WS-I)
             COMPUTE WS-CELL-BLOCK(WS-I) = CB-S-BLOCK(WS-STATE + 1)
             COMPUTE WS-Y = WS-FLOOR + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         END-IF
     END-PERFORM
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     IF WS-BREAK > 0
         MOVE 0 TO WS-ACTION
         COMPUTE WS-Y = WS-FLOOR + WS-BREAK
         ADD 1 TO WS-SEQ
         CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-PX WS-Y WS-PZ WS-FACE WS-SEQ
     END-IF
     IF WS-SIDE-STONE > 0
         COMPUTE WS-X = WS-PX + 1
         COMPUTE WS-Y = WS-FLOOR + WS-SIDE-STONE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-PZ WS-STONE
     END-IF
     MOVE SPACES TO WS-TRACE
     MOVE 1 TO WS-TRACE-AT
     PERFORM TRACE-COLUMN
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 8
         MOVE 1 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         PERFORM TRACE-COLUMN
     END-PERFORM
     DISPLAY "TRACE " FUNCTION TRIM(WS-LABEL) ": " FUNCTION TRIM(WS-TRACE)
     MOVE SPACES TO WS-CASE
     STRING "acceptance plant columns standard: " FUNCTION TRIM(WS-LABEL) ": the column right after the break (same tick)" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-WANT TO TL-EXPECTED
     MOVE WS-TRACE(1:9) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance plant columns standard: " FUNCTION TRIM(WS-LABEL) ": the column after three ticks" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-WANT3 TO TL-EXPECTED
     MOVE WS-TRACE(31:9) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Appends the nine cells and a space to WS-TRACE.
 TRACE-COLUMN.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         MOVE "?" TO WS-CH
         IF WS-STATE = 0
             MOVE "." TO WS-CH
         END-IF
         IF WS-STATE = WS-WATER
             MOVE "w" TO WS-CH
         END-IF
         COMPUTE WS-BLK = CB-S-BLOCK(WS-STATE + 1)
         PERFORM VARYING WS-K FROM 9 BY -1 UNTIL WS-K < 1
             IF WS-CELL-BLOCK(WS-K) = WS-BLK AND WS-STATE NOT = 0 AND WS-CELL-SPEC(WS-K) NOT = SPACES
                 MOVE WS-K TO WS-DIGIT
                 MOVE WS-DIGIT(2:1) TO WS-CH
             END-IF
         END-PERFORM
         MOVE WS-CH TO WS-TRACE(WS-TRACE-AT:1)
         ADD 1 TO WS-TRACE-AT
     END-PERFORM
     MOVE " " TO WS-TRACE(WS-TRACE-AT:1)
     ADD 1 TO WS-TRACE-AT.

*> WS-STATE: the state of WS-SPEC, "key[name=value,name=value]": the block's default state with each property set.
 SPEC-STATE.
     MOVE 0 TO WS-STATE
     MOVE SPACES TO WS-SPEC-KEY WS-SPEC-PROPS
     MOVE 0 TO WS-BRACKET
     INSPECT WS-SPEC TALLYING WS-BRACKET FOR CHARACTERS BEFORE INITIAL "["
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC))
     IF WS-BRACKET < WS-LEN
         MOVE WS-SPEC(1:WS-BRACKET) TO WS-SPEC-KEY
         COMPUTE WS-LEFT = WS-LEN - WS-BRACKET - 2
         COMPUTE WS-E = WS-BRACKET + 2
         MOVE WS-SPEC(WS-E:WS-LEFT) TO WS-SPEC-PROPS
     ELSE
         MOVE FUNCTION TRIM(WS-SPEC) TO WS-SPEC-KEY
     END-IF
     MOVE SPACES TO WS-KEY112
     STRING "minecraft:" FUNCTION TRIM(WS-SPEC-KEY) DELIMITED BY SIZE INTO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-E
     IF WS-E >= 0
         MOVE CB-DEFAULT-STATE(WS-E + 1) TO WS-STATE
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-SPEC-PROPS = SPACES OR WS-POINTER > FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC-PROPS))
             MOVE SPACES TO WS-PAIR
             UNSTRING WS-SPEC-PROPS DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POINTER
             MOVE SPACES TO WS-PAIR-NAME WS-PAIR-VALUE
             UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-PAIR-NAME WS-PAIR-VALUE
             CALL "PS-PUT" USING WS-STATE WS-PAIR-NAME WS-PAIR-VALUE
         END-PERFORM
     END-IF.
 END PROGRAM ACC-PLANT-COLUMNS-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
